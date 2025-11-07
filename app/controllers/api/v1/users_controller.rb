module Api
  module V1
    class UsersController < BaseController
      before_action :authenticate_request
      before_action :set_user, only: [:show, :update, :destroy, :activate, :deactivate]

      # GET /api/v1/users
      # List users (filtered by authorization scope)
      # Admins/HR: all users
      # Managers: users in their department
      # Employees: only themselves
      def index
        authorize User
        users = policy_scope(User).active.order(:name)

        # Search
        users = users.search(params[:q]) if params[:q].present?

        # Optional filters
        users = users.by_role(params[:role]) if params[:role].present?
        users = users.in_department(params[:department_id]) if params[:department_id].present?

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        users = users.page(page).per(per_page)

        render json: {
          data: users.map { |user| user_response(user) },
          meta: pagination_meta(users)
        }, status: :ok
      end

      # GET /api/v1/users/:id
      # Show user details
      def show
        authorize @user
        render json: {
          data: user_response(@user, detailed: true)
        }, status: :ok
      end

      # POST /api/v1/users
      # Create new user (admin/HR only)
      def create
        user = User.new(user_params)
        authorize user

        if user.save
          render json: {
            data: user_response(user, detailed: true)
          }, status: :created
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      # Update user
      def update
        authorize @user

        # Get permitted attributes based on policy
        permitted_attrs = policy(@user).permitted_attributes
        update_params = params.require(:user).permit(*permitted_attrs)

        if @user.update(update_params)
          render json: {
            data: user_response(@user, detailed: true)
          }, status: :ok
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      # Soft delete user (deactivate)
      def destroy
        authorize @user

        if @user.update(active: false)
          render json: {
            message: 'User deactivated successfully'
          }, status: :ok
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/:id/activate
      # Activate user (admin/HR only)
      def activate
        authorize @user, :activate?

        if @user.update(active: true)
          render json: {
            data: user_response(@user, detailed: true),
            message: 'User activated successfully'
          }, status: :ok
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/users/:id/deactivate
      # Deactivate user (admin/HR only)
      def deactivate
        authorize @user, :deactivate?

        if @user.update(active: false)
          render json: {
            data: user_response(@user, detailed: true),
            message: 'User deactivated successfully'
          }, status: :ok
        else
          render json: {
            errors: @user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/users/:id/update_password
      # Update user password (own profile only)
      def update_password
        user = User.find(params[:id])
        authorize user, :update_password?

        unless user.authenticate(params[:current_password])
          return render json: {
            errors: ['Current password is incorrect']
          }, status: :unauthorized
        end

        if user.update(
          password: params[:new_password],
          password_confirmation: params[:password_confirmation]
        )
          render json: {
            message: 'Password updated successfully'
          }, status: :ok
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        # Use policy to determine permitted attributes
        policy = UserPolicy.new(current_user, User.new)
        params.require(:user).permit(*policy.permitted_attributes)
      end

      def user_response(user, detailed: false)
        response = {
          id: user.id,
          email: user.email,
          name: user.name,
          role: user.role,
          active: user.active
        }

        if detailed
          response.merge!({
            phone: user.phone,
            department_id: user.department_id,
            department_name: user.department&.name,
            created_at: user.created_at,
            updated_at: user.updated_at,
            assignments_count: user.assignments.count,
            upcoming_shifts_count: user.shifts.where('start_time >= ?', Time.current).count
          })
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
    end
  end
end
