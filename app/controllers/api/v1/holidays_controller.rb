# frozen_string_literal: true

module Api
  module V1
    # HolidaysController handles CRUD operations for holidays
    class HolidaysController < BaseController
      before_action :set_holiday, only: [:show, :update, :destroy]

      # GET /api/v1/holidays
      # List holidays (all users can view)
      def index
        holidays = Holiday.all

        # Apply filters
        holidays = holidays.upcoming if params[:upcoming] == 'true'
        holidays = holidays.past if params[:past] == 'true'
        holidays = holidays.for_year(params[:year].to_i) if params[:year].present?
        holidays = holidays.for_month(params[:year].to_i, params[:month].to_i) if params[:year].present? && params[:month].present?

        # Date range filter
        if params[:start_date].present? && params[:end_date].present?
          holidays = holidays.where(date: params[:start_date]..params[:end_date])
        end

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        holidays = holidays.page(page).per(per_page).order(:date)

        render json: {
          data: holidays.map { |holiday| holiday_response(holiday) },
          meta: pagination_meta(holidays)
        }, status: :ok
      end

      # GET /api/v1/holidays/:id
      def show
        render json: { data: holiday_response(@holiday) }, status: :ok
      end

      # POST /api/v1/holidays
      # Create holiday (admin only)
      def create
        unless current_user.admin?
          return render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end

        holiday = Holiday.new(holiday_params)

        if holiday.save
          render json: { data: holiday_response(holiday) }, status: :created
        else
          render json: { errors: holiday.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/holidays/:id
      # Update holiday (admin only)
      def update
        unless current_user.admin?
          return render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end

        if @holiday.update(holiday_params)
          render json: { data: holiday_response(@holiday) }, status: :ok
        else
          render json: { errors: @holiday.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/holidays/:id
      # Delete holiday (admin only)
      def destroy
        unless current_user.admin?
          return render json: { errors: ['You are not authorized to perform this action'] }, status: :forbidden
        end

        @holiday.destroy
        head :no_content
      end

      # GET /api/v1/holidays/check
      # Check if a specific date is a holiday
      def check
        date = params[:date].present? ? Date.parse(params[:date]) : Date.current

        if Holiday.is_holiday?(date)
          holiday = Holiday.find_by(date: date)
          render json: {
            is_holiday: true,
            holiday: holiday_response(holiday)
          }, status: :ok
        else
          render json: { is_holiday: false, holiday: nil }, status: :ok
        end
      rescue Date::Error
        render json: { errors: ['Invalid date format. Use YYYY-MM-DD'] }, status: :bad_request
      end

      private

      def set_holiday
        @holiday = Holiday.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ['Holiday not found'] }, status: :not_found
      end

      def holiday_params
        params.permit(:name, :date)
      end

      def holiday_response(holiday)
        {
          id: holiday.id,
          name: holiday.name,
          date: holiday.date,
          is_upcoming: holiday.upcoming?,
          is_past: holiday.past?,
          is_today: holiday.today?,
          created_at: holiday.created_at,
          updated_at: holiday.updated_at
        }
      end
    end
  end
end
