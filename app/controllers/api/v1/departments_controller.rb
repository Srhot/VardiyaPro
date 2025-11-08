# frozen_string_literal: true

module Api
  module V1
    class DepartmentsController < BaseController
      skip_before_action :authenticate_request, only: %i[index show]

      # GET /api/v1/departments
      def index
        departments = Department.active.order(:name)

        # Search
        departments = departments.search(params[:q]) if params[:q].present?

        render json: {
          data: departments.map { |dept| department_response(dept) }
        }, status: :ok
      end

      # GET /api/v1/departments/:id
      def show
        department = Department.find(params[:id])
        render json: {
          data: department_response(department)
        }, status: :ok
      end

      # POST /api/v1/departments (admin only)
      def create
        return unauthorized unless current_user&.admin?

        department = Department.new(department_params)
        if department.save
          render json: {
            data: department_response(department)
          }, status: :created
        else
          render json: {
            errors: department.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/departments/:id (admin only)
      def update
        return unauthorized unless current_user&.admin?

        department = Department.find(params[:id])
        if department.update(department_params)
          render json: {
            data: department_response(department)
          }, status: :ok
        else
          render json: {
            errors: department.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      private

      def department_params
        params.require(:department).permit(:name, :description, :active)
      end

      def department_response(dept)
        {
          id: dept.id,
          name: dept.name,
          description: dept.description,
          active: dept.active,
          users_count: dept.users.count,
          created_at: dept.created_at,
          updated_at: dept.updated_at
        }
      end

      def unauthorized
        render json: { errors: ['Admin access required'] }, status: :forbidden
      end
    end
  end
end
