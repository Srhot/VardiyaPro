module Api
  module V1
    class AssignmentsController < BaseController
      skip_before_action :authenticate_request, only: [:index, :show]

      # GET /api/v1/assignments
      def index
        assignments = Assignment.includes(:shift, :employee).all

        # Filtering
        assignments = assignments.for_employee(params[:employee_id]) if params[:employee_id].present?
        assignments = assignments.for_shift(params[:shift_id]) if params[:shift_id].present?
        assignments = assignments.where(status: params[:status]) if params[:status].present?

        # Date range filtering
        if params[:start_date].present? && params[:end_date].present?
          assignments = assignments.joins(:shift).where(
            'shifts.start_time >= ? AND shifts.end_time <= ?',
            params[:start_date],
            params[:end_date]
          )
        end

        assignments = assignments.order('shifts.start_time DESC')

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25

        paginated_assignments = assignments.page(page).per(per_page)

        render json: {
          data: paginated_assignments.map { |assignment| assignment_response(assignment) },
          meta: pagination_meta(paginated_assignments)
        }, status: :ok
      end

      # GET /api/v1/assignments/:id
      def show
        assignment = Assignment.includes(:shift, :employee).find(params[:id])
        render json: {
          data: assignment_response(assignment, detailed: true)
        }, status: :ok
      end

      # POST /api/v1/assignments (admin/hr/manager only)
      def create
        return unauthorized unless can_manage_assignments?

        assignment = Assignment.new(assignment_params)

        if assignment.save
          render json: {
            data: assignment_response(assignment)
          }, status: :created
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/assignments/:id (admin/hr/manager only)
      def update
        return unauthorized unless can_manage_assignments?

        assignment = Assignment.find(params[:id])

        if assignment.update(assignment_update_params)
          render json: {
            data: assignment_response(assignment)
          }, status: :ok
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/assignments/:id (admin only)
      def destroy
        return unauthorized unless current_user&.admin?

        assignment = Assignment.find(params[:id])
        if assignment.destroy
          render json: {
            message: 'Assignment deleted successfully'
          }, status: :ok
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/assignments/:id/confirm (admin/hr/manager only)
      def confirm
        return unauthorized unless can_manage_assignments?

        assignment = Assignment.find(params[:id])
        if assignment.update(status: 'confirmed')
          render json: {
            data: assignment_response(assignment),
            message: 'Assignment confirmed successfully'
          }, status: :ok
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/assignments/:id/complete (admin/hr/manager only)
      def complete
        return unauthorized unless can_manage_assignments?

        assignment = Assignment.find(params[:id])
        if assignment.update(status: 'completed')
          render json: {
            data: assignment_response(assignment),
            message: 'Assignment marked as completed'
          }, status: :ok
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/assignments/:id/cancel (admin/hr/manager only)
      def cancel
        return unauthorized unless can_manage_assignments?

        assignment = Assignment.find(params[:id])
        if assignment.update(status: 'cancelled')
          render json: {
            data: assignment_response(assignment),
            message: 'Assignment cancelled successfully'
          }, status: :ok
        else
          render json: {
            errors: assignment.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def assignment_params
        params.require(:assignment).permit(:shift_id, :employee_id, :status, :notes)
      end

      def assignment_update_params
        params.require(:assignment).permit(:status, :notes)
      end

      def assignment_response(assignment, detailed: false)
        response = {
          id: assignment.id,
          shift: {
            id: assignment.shift.id,
            shift_type: assignment.shift.shift_type,
            start_time: assignment.shift.start_time,
            end_time: assignment.shift.end_time,
            department: {
              id: assignment.shift.department.id,
              name: assignment.shift.department.name
            }
          },
          employee: {
            id: assignment.employee.id,
            name: assignment.employee.name,
            email: assignment.employee.email,
            role: assignment.employee.role
          },
          status: assignment.status,
          notes: assignment.notes,
          created_at: assignment.created_at,
          updated_at: assignment.updated_at
        }

        if detailed
          response[:shift][:description] = assignment.shift.description
          response[:shift][:required_staff] = assignment.shift.required_staff
          response[:shift][:available_slots] = assignment.shift.available_slots
          response[:employee][:phone] = assignment.employee.phone
        end

        response
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

      def can_manage_assignments?
        current_user&.admin? || current_user&.hr? || current_user&.manager?
      end

      def unauthorized
        render json: { errors: ['Admin, HR, or Manager access required'] }, status: :forbidden
      end
    end
  end
end
