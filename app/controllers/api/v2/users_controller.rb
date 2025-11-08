# frozen_string_literal: true

module Api
  module V2
    class UsersController < BaseController
      before_action :authenticate_request
      before_action :set_user, only: %i[show profile statistics]

      # Inherited from v1:
      # - index
      # - show
      # - create
      # - update
      # We'll add v2-specific enhancements

      # GET /api/v2/users
      # Enhanced with additional fields
      def index
        authorize User
        users = policy_scope(User).active.order(:name)

        # Search
        users = users.search(params[:q]) if params[:q].present?

        # Filters
        users = users.by_role(params[:role]) if params[:role].present?
        users = users.in_department(params[:department_id]) if params[:department_id].present?

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        users = users.page(page).per(per_page)

        render json: {
          data: users.map { |user| user_response_v2(user) },
          meta: pagination_meta(users),
          api_version: 'v2'
        }, status: :ok
      end

      # GET /api/v2/users/:id/profile
      # NEW in v2: Enhanced profile with statistics
      def profile
        authorize @user

        profile_data = {
          user: user_response_v2(@user, detailed: true),
          statistics: {
            total_shifts: @user.assignments.count,
            confirmed_shifts: @user.assignments.confirmed.count,
            completed_shifts: @user.assignments.completed.count,
            total_hours_this_month: calculate_total_hours(@user, Date.current.beginning_of_month,
                                                          Date.current.end_of_month),
            upcoming_shifts: @user.shifts.where('start_time >= ?', Time.current).count
          },
          recent_activity: {
            last_shift: @user.assignments.joins(:shift)
                             .order('shifts.start_time DESC')
                             .first&.shift&.start_time,
            last_login: nil # TODO: Add last_login tracking
          },
          performance_metrics: {
            attendance_rate: calculate_attendance_rate(@user),
            average_hours_per_week: calculate_avg_hours_per_week(@user)
          }
        }

        render json: {
          data: profile_data,
          api_version: 'v2'
        }, status: :ok
      end

      # GET /api/v2/users/:id/statistics
      # NEW in v2: Detailed user statistics
      def statistics
        authorize @user

        start_date = params[:start_date]&.to_date || 30.days.ago
        end_date = params[:end_date]&.to_date || Date.current

        assignments = @user.assignments
                           .joins(:shift)
                           .where('shifts.start_time >= ? AND shifts.end_time <= ?', start_date, end_date)

        stats = {
          period: {
            start_date: start_date,
            end_date: end_date,
            days: (end_date - start_date).to_i
          },
          assignments: {
            total: assignments.count,
            by_status: {
              pending: assignments.pending.count,
              confirmed: assignments.confirmed.count,
              completed: assignments.completed.count,
              cancelled: assignments.cancelled.count
            }
          },
          hours: {
            total: calculate_total_hours(@user, start_date, end_date),
            by_shift_type: hours_by_shift_type(@user, start_date, end_date),
            average_per_week: calculate_avg_hours_per_week(@user, start_date, end_date)
          },
          shifts: {
            most_common_type: most_common_shift_type(@user, start_date, end_date),
            busiest_day_of_week: busiest_day_of_week(@user, start_date, end_date)
          }
        }

        render json: {
          data: stats,
          api_version: 'v2'
        }, status: :ok
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      # Enhanced user response with v2 additional fields
      def user_response_v2(user, detailed: false)
        response = {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          active: user.active,
          version: 'v2' # Version indicator
        }

        if detailed
          response.merge!({
                            phone: user.phone,
                            department_id: user.department_id,
                            department_name: user.department&.name,
                            created_at: user.created_at,
                            updated_at: user.updated_at,
                            assignments_count: user.assignments.count,
                            upcoming_shifts_count: user.shifts.where('start_time >= ?', Time.current).count,
                            # NEW in v2:
                            total_hours_this_month: calculate_total_hours(user, Date.current.beginning_of_month,
                                                                          Date.current.end_of_month),
                            attendance_rate: calculate_attendance_rate(user)
                          })
        end

        response
      end

      def calculate_total_hours(user, start_date, end_date)
        user.assignments
            .confirmed.or(user.assignments.completed)
            .joins(:shift)
            .where('shifts.start_time >= ? AND shifts.end_time <= ?', start_date, end_date)
            .sum('EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600')
            .to_f
            .round(2)
      end

      def calculate_attendance_rate(user)
        total = user.assignments.where('created_at >= ?', 90.days.ago).count
        return 0.0 if total.zero?

        completed = user.assignments.completed.where('created_at >= ?', 90.days.ago).count
        ((completed.to_f / total) * 100).round(2)
      end

      def calculate_avg_hours_per_week(user, start_date = 30.days.ago, end_date = Date.current)
        total_hours = calculate_total_hours(user, start_date, end_date)
        weeks = ((end_date - start_date) / 7.0).ceil
        return 0.0 if weeks.zero?

        (total_hours / weeks).round(2)
      end

      def hours_by_shift_type(user, start_date, end_date)
        user.assignments
            .confirmed.or(user.assignments.completed)
            .joins(:shift)
            .where('shifts.start_time >= ? AND shifts.end_time <= ?', start_date, end_date)
            .group('shifts.shift_type')
            .sum('EXTRACT(EPOCH FROM (shifts.end_time - shifts.start_time)) / 3600')
            .transform_values { |v| v.to_f.round(2) }
      end

      def most_common_shift_type(user, start_date, end_date)
        user.assignments
            .joins(:shift)
            .where('shifts.start_time >= ? AND shifts.end_time <= ?', start_date, end_date)
            .group('shifts.shift_type')
            .order('count_all DESC')
            .limit(1)
            .count
            .keys
            .first
      end

      def busiest_day_of_week(user, start_date, end_date)
        day_counts = user.assignments
                         .joins(:shift)
                         .where('shifts.start_time >= ? AND shifts.end_time <= ?', start_date, end_date)
                         .group('EXTRACT(DOW FROM shifts.start_time)')
                         .count

        return nil if day_counts.empty?

        busiest_day_number = day_counts.max_by { |_day, count| count }[0].to_i
        Date::DAYNAMES[busiest_day_number]
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
