module Api
  module V1
    class ReportsController < BaseController
      before_action :authenticate_request
      before_action :set_date_range

      # GET /api/v1/reports/employee/:id
      # Employee shift report with hours, assignments, and department breakdown
      def employee
        employee = User.find(params[:id])

        # Authorization: admin/hr see all, managers see same dept, employees see own
        unless current_user.admin? || current_user.hr? ||
               (current_user.manager? && current_user.department_id == employee.department_id) ||
               current_user.id == employee.id
          return render json: { errors: ['Unauthorized'] }, status: :forbidden
        end

        # Get assignments in date range
        assignments = employee.assignments
                              .joins(:shift)
                              .where('shifts.start_time >= ? AND shifts.end_time <= ?', @start_date, @end_date)

        # Calculate statistics
        total_assignments = assignments.count
        confirmed_assignments = assignments.confirmed.count
        completed_assignments = assignments.completed.count
        cancelled_assignments = assignments.cancelled.count

        # Calculate total hours
        total_hours = assignments.confirmed.or(assignments.completed).joins(:shift).sum('EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600')

        # Shift type breakdown
        shift_type_breakdown = assignments.confirmed.or(assignments.completed)
                                        .joins(:shift)
                                        .group('shifts.shift_type')
                                        .select('shifts.shift_type, COUNT(*) as count, SUM(EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600) as hours')
                                        .map { |s| { shift_type: s.shift_type, count: s.count, hours: s.hours.to_f.round(2) } }

        # Recent assignments
        recent_assignments = assignments.order('shifts.start_time DESC')
                                      .limit(10)
                                      .map do |assignment|
          {
            id: assignment.id,
            shift_type: assignment.shift.shift_type,
            start_time: assignment.shift.start_time,
            end_time: assignment.shift.end_time,
            hours: assignment.shift.duration_hours,
            status: assignment.status,
            department: assignment.shift.department.name
          }
        end

        render json: {
          data: {
            employee: {
              id: employee.id,
              name: employee.name,
              email: employee.email,
              department: employee.department&.name,
              role: employee.role
            },
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            statistics: {
              total_assignments: total_assignments,
              confirmed_assignments: confirmed_assignments,
              completed_assignments: completed_assignments,
              cancelled_assignments: cancelled_assignments,
              total_hours: total_hours.to_f.round(2)
            },
            shift_type_breakdown: shift_type_breakdown,
            recent_assignments: recent_assignments
          }
        }, status: :ok
      end

      # GET /api/v1/reports/department/:id
      # Department report with employee statistics and shift distribution
      def department
        department = Department.find(params[:id])

        # Authorization: admin/hr see all, managers see own dept only
        unless current_user.admin? || current_user.hr? ||
               (current_user.manager? && current_user.department_id == department.id)
          return render json: { errors: ['Unauthorized'] }, status: :forbidden
        end

        # Get shifts in date range
        shifts = department.shifts
                          .where('start_time >= ? AND end_time <= ?', @start_date, @end_date)

        # Employee statistics
        employees = department.users.active
        employee_stats = employees.map do |employee|
          assignments = employee.assignments
                              .joins(:shift)
                              .where(shift_id: shifts.pluck(:id))

          total_hours = assignments.confirmed.or(assignments.completed)
                                  .joins(:shift)
                                  .sum('EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600')

          {
            id: employee.id,
            name: employee.name,
            role: employee.role,
            total_assignments: assignments.count,
            confirmed_assignments: assignments.confirmed.count,
            total_hours: total_hours.to_f.round(2)
          }
        end

        # Shift statistics
        total_shifts = shifts.count
        total_assignments = Assignment.where(shift_id: shifts.pluck(:id)).count
        confirmed_assignments = Assignment.where(shift_id: shifts.pluck(:id)).confirmed.count

        # Shift type distribution
        shift_type_distribution = shifts.group(:shift_type)
                                       .select('shift_type, COUNT(*) as count')
                                       .map { |s| { shift_type: s.shift_type, count: s.count } }

        # Coverage rate (confirmed assignments / required staff)
        total_required_staff = shifts.sum(:required_staff)
        coverage_rate = total_required_staff > 0 ? (confirmed_assignments.to_f / total_required_staff * 100).round(2) : 0

        render json: {
          data: {
            department: {
              id: department.id,
              name: department.name,
              description: department.description
            },
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            statistics: {
              total_employees: employees.count,
              total_shifts: total_shifts,
              total_assignments: total_assignments,
              confirmed_assignments: confirmed_assignments,
              total_required_staff: total_required_staff,
              coverage_rate: coverage_rate
            },
            shift_type_distribution: shift_type_distribution,
            employee_statistics: employee_stats.sort_by { |e| -e[:total_hours] }
          }
        }, status: :ok
      end

      # GET /api/v1/reports/overtime
      # Overtime report showing employees exceeding standard hours
      def overtime
        # Authorization: admin, hr, and managers only
        unless current_user.admin? || current_user.hr? || current_user.manager?
          return render json: { errors: ['Unauthorized'] }, status: :forbidden
        end

        # Standard work hours per week (configurable)
        standard_hours_per_week = params[:standard_hours]&.to_f || 40.0

        # Calculate weeks in date range
        weeks = ((@end_date - @start_date) / 1.week).ceil
        standard_hours_total = standard_hours_per_week * weeks

        # Get all employees (filtered by department for managers)
        employees = if current_user.manager?
                     User.active.where(department_id: current_user.department_id)
                   else
                     User.active
                   end

        overtime_data = employees.map do |employee|
          # Get assignments in date range
          assignments = employee.assignments
                               .confirmed.or(employee.assignments.completed)
                               .joins(:shift)
                               .where('shifts.start_time >= ? AND shifts.end_time <= ?', @start_date, @end_date)

          total_hours = assignments.sum('EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600').to_f.round(2)
          overtime_hours = [total_hours - standard_hours_total, 0].max.round(2)

          # Only include employees with overtime
          next if overtime_hours <= 0

          {
            id: employee.id,
            name: employee.name,
            department: employee.department&.name,
            role: employee.role,
            total_hours: total_hours,
            standard_hours: standard_hours_total,
            overtime_hours: overtime_hours,
            total_shifts: assignments.count
          }
        end.compact

        render json: {
          data: {
            period: {
              start_date: @start_date,
              end_date: @end_date,
              weeks: weeks
            },
            parameters: {
              standard_hours_per_week: standard_hours_per_week,
              standard_hours_total: standard_hours_total
            },
            statistics: {
              employees_with_overtime: overtime_data.count,
              total_overtime_hours: overtime_data.sum { |e| e[:overtime_hours] }.round(2)
            },
            overtime_employees: overtime_data.sort_by { |e| -e[:overtime_hours] }
          }
        }, status: :ok
      end

      # GET /api/v1/reports/summary
      # Overall summary report for admins and HR
      def summary
        # Authorization: admin and hr only
        unless current_user.admin? || current_user.hr?
          return render json: { errors: ['Admin or HR access required'] }, status: :forbidden
        end

        # Department statistics
        departments = Department.active.map do |dept|
          shifts = dept.shifts.where('start_time >= ? AND end_time <= ?', @start_date, @end_date)
          assignments = Assignment.where(shift_id: shifts.pluck(:id))

          {
            id: dept.id,
            name: dept.name,
            total_employees: dept.users.active.count,
            total_shifts: shifts.count,
            total_assignments: assignments.count,
            confirmed_assignments: assignments.confirmed.count
          }
        end

        # Overall statistics
        total_employees = User.active.count
        total_shifts = Shift.where('start_time >= ? AND end_time <= ?', @start_date, @end_date).count
        total_assignments = Assignment.joins(:shift).where('shifts.start_time >= ? AND shifts.end_time <= ?', @start_date, @end_date).count

        render json: {
          data: {
            period: {
              start_date: @start_date,
              end_date: @end_date
            },
            overall_statistics: {
              total_employees: total_employees,
              total_departments: departments.count,
              total_shifts: total_shifts,
              total_assignments: total_assignments
            },
            department_statistics: departments
          }
        }, status: :ok
      end

      private

      def set_date_range
        # Default to current month if not provided
        @start_date = params[:start_date]&.to_date || Date.current.beginning_of_month
        @end_date = params[:end_date]&.to_date || Date.current.end_of_month
      end
    end
  end
end
