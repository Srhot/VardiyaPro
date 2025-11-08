# frozen_string_literal: true

module Api
  module V1
    # TimeEntriesController handles clock in/out operations
    class TimeEntriesController < ApplicationController
      before_action :authenticate_user!
      before_action :set_assignment, only: [:clock_in]
      before_action :set_time_entry, only: [:clock_out, :show, :update]

      # GET /api/v1/time_entries
      # List time entries (filtered by employee for non-admin users)
      def index
        time_entries = if current_user.admin? || current_user.hr?
                         TimeEntry.includes(assignment: [:employee, :shift])
                       else
                         TimeEntry.joins(:assignment).where(assignments: { employee_id: current_user.id })
                       end

        # Apply filters
        time_entries = time_entries.for_date_range(params[:start_date], params[:end_date]) if params[:start_date] && params[:end_date]
        time_entries = time_entries.clocked_in if params[:status] == 'clocked_in'
        time_entries = time_entries.clocked_out if params[:status] == 'clocked_out'

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        time_entries = time_entries.page(page).per(per_page)

        render json: {
          data: time_entries.map { |entry| time_entry_response(entry) },
          meta: pagination_meta(time_entries)
        }, status: :ok
      end

      # GET /api/v1/time_entries/:id
      def show
        authorize_time_entry_access!

        render json: { data: time_entry_response(@time_entry) }, status: :ok
      end

      # POST /api/v1/assignments/:assignment_id/clock_in
      # Clock in for an assignment
      def clock_in
        authorize_assignment_access!

        if @assignment.time_entry.present?
          return render json: { errors: ['Time entry already exists for this assignment'] }, status: :unprocessable_entity
        end

        if @assignment.status != 'confirmed'
          return render json: { errors: ['Assignment must be confirmed before clocking in'] }, status: :unprocessable_entity
        end

        time_entry = @assignment.build_time_entry(
          clock_in_time: Time.current,
          notes: params[:notes]
        )

        if time_entry.save
          render json: { data: time_entry_response(time_entry) }, status: :created
        else
          render json: { errors: time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/time_entries/:id/clock_out
      # Clock out from an assignment
      def clock_out
        authorize_time_entry_access!

        if @time_entry.clocked_out?
          return render json: { errors: ['Already clocked out'] }, status: :unprocessable_entity
        end

        if @time_entry.update(clock_out_time: Time.current, notes: params[:notes] || @time_entry.notes)
          # Update assignment status to completed
          @time_entry.assignment.update(status: 'completed')

          render json: { data: time_entry_response(@time_entry) }, status: :ok
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/time_entries/:id
      # Update time entry (admin/hr only - for corrections)
      def update
        unless current_user.admin? || current_user.hr?
          return render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end

        if @time_entry.update(time_entry_params)
          render json: { data: time_entry_response(@time_entry) }, status: :ok
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/time_entries/:id
      # Delete time entry (admin only)
      def destroy
        unless current_user.admin?
          return render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end

        set_time_entry
        @time_entry.destroy
        head :no_content
      end

      private

      def set_assignment
        @assignment = Assignment.find(params[:assignment_id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Assignment not found'] }, status: :not_found
      end

      def set_time_entry
        @time_entry = TimeEntry.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Time entry not found'] }, status: :not_found
      end

      def authorize_assignment_access!
        unless current_user.id == @assignment.employee_id || current_user.admin? || current_user.manager?
          render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end
      end

      def authorize_time_entry_access!
        unless current_user.id == @time_entry.assignment.employee_id || current_user.admin? || current_user.hr?
          render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end
      end

      def time_entry_params
        params.permit(:clock_in_time, :clock_out_time, :notes)
      end

      def time_entry_response(time_entry)
        {
          id: time_entry.id,
          assignment_id: time_entry.assignment_id,
          assignment: {
            id: time_entry.assignment.id,
            status: time_entry.assignment.status,
            shift: {
              id: time_entry.assignment.shift.id,
              shift_type: time_entry.assignment.shift.shift_type,
              start_time: time_entry.assignment.shift.start_time,
              end_time: time_entry.assignment.shift.end_time,
              description: time_entry.assignment.shift.description
            }
          },
          employee: {
            id: time_entry.assignment.employee.id,
            name: time_entry.assignment.employee.name,
            email: time_entry.assignment.employee.email
          },
          clock_in_time: time_entry.clock_in_time,
          clock_out_time: time_entry.clock_out_time,
          worked_hours: time_entry.worked_hours,
          notes: time_entry.notes,
          created_at: time_entry.created_at,
          updated_at: time_entry.updated_at
        }
      end
    end
  end
end
