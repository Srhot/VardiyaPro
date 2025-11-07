module Api
  module V1
    class ShiftsController < BaseController
      skip_before_action :authenticate_request, only: [:index, :show]

      # GET /api/v1/shifts
      def index
        shifts = Shift.includes(:department).active

        # Filtering
        shifts = shifts.by_department(params[:department_id]) if params[:department_id].present?
        shifts = shifts.by_type(params[:shift_type]) if params[:shift_type].present?

        if params[:start_date].present? && params[:end_date].present?
          shifts = shifts.in_range(params[:start_date], params[:end_date])
        elsif params[:upcoming] == 'true'
          shifts = shifts.upcoming
        else
          shifts = shifts.order(:start_time)
        end

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25

        paginated_shifts = shifts.page(page).per(per_page)

        render json: {
          data: paginated_shifts.map { |shift| shift_response(shift) },
          meta: pagination_meta(paginated_shifts)
        }, status: :ok
      end

      # GET /api/v1/shifts/:id
      def show
        shift = Shift.includes(:department, :assignments).find(params[:id])
        render json: {
          data: shift_response(shift, include_assignments: true)
        }, status: :ok
      end

      # POST /api/v1/shifts (admin/hr only)
      def create
        return unauthorized unless current_user&.admin? || current_user&.hr?

        shift = Shift.new(shift_params)
        if shift.save
          render json: {
            data: shift_response(shift)
          }, status: :created
        else
          render json: {
            errors: shift.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/shifts/:id (admin/hr only)
      def update
        return unauthorized unless current_user&.admin? || current_user&.hr?

        shift = Shift.find(params[:id])
        if shift.update(shift_params)
          render json: {
            data: shift_response(shift)
          }, status: :ok
        else
          render json: {
            errors: shift.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/shifts/:id (admin only - soft delete)
      def destroy
        return unauthorized unless current_user&.admin?

        shift = Shift.find(params[:id])
        if shift.update(active: false)
          render json: {
            message: 'Shift deactivated successfully'
          }, status: :ok
        else
          render json: {
            errors: shift.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def shift_params
        params.require(:shift).permit(
          :department_id,
          :shift_type,
          :start_time,
          :end_time,
          :required_staff,
          :description,
          :active
        )
      end

      def shift_response(shift, include_assignments: false)
        response = {
          id: shift.id,
          department: {
            id: shift.department.id,
            name: shift.department.name
          },
          shift_type: shift.shift_type,
          start_time: shift.start_time,
          end_time: shift.end_time,
          duration_hours: shift.duration_hours,
          required_staff: shift.required_staff,
          available_slots: shift.available_slots,
          filled: shift.filled?,
          description: shift.description,
          active: shift.active,
          created_at: shift.created_at,
          updated_at: shift.updated_at
        }

        if include_assignments
          response[:assignments] = shift.assignments.includes(:user).map do |assignment|
            {
              id: assignment.id,
              user: {
                id: assignment.user.id,
                name: assignment.user.name,
                email: assignment.user.email
              },
              status: assignment.status
            }
          end
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

      def unauthorized
        render json: { errors: ['Admin or HR access required'] }, status: :forbidden
      end
    end
  end
end
