# frozen_string_literal: true

module Api
  module V1
    class AuditLogsController < BaseController
      before_action :authenticate_request
      before_action :authorize_admin

      # GET /api/v1/audit_logs
      # List audit logs (admin only)
      def index
        logs = AuditLog.includes(:user).recent

        # Filtering
        logs = logs.by_user(params[:user_id]) if params[:user_id].present?
        logs = logs.by_action(params[:action]) if params[:action].present?
        logs = logs.by_auditable_type(params[:auditable_type]) if params[:auditable_type].present?

        # Date range
        logs = logs.where('created_at >= ?', params[:start_date]) if params[:start_date].present?
        logs = logs.where('created_at <= ?', params[:end_date]) if params[:end_date].present?

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 50

        paginated_logs = logs.page(page).per(per_page)

        render json: {
          data: paginated_logs.map { |log| audit_log_response(log) },
          meta: pagination_meta(paginated_logs)
        }, status: :ok
      end

      # GET /api/v1/audit_logs/:id
      # Show audit log details (admin only)
      def show
        log = AuditLog.includes(:user, :auditable).find(params[:id])
        render json: {
          data: audit_log_response(log, detailed: true)
        }, status: :ok
      end

      # GET /api/v1/audit_logs/for_record
      # Get audit logs for a specific record (admin only)
      def for_record
        unless params[:auditable_type].present? && params[:auditable_id].present?
          return render json: {
            errors: ['auditable_type and auditable_id are required']
          }, status: :bad_request
        end

        logs = AuditLog.for_record(params[:auditable_type], params[:auditable_id])
                       .includes(:user)
                       .recent

        render json: {
          data: logs.map { |log| audit_log_response(log, detailed: true) }
        }, status: :ok
      end

      private

      def authorize_admin
        return if current_user&.admin?

        render json: { errors: ['Admin access required'] }, status: :forbidden
      end

      def audit_log_response(log, detailed: false)
        response = {
          id: log.id,
          user_id: log.user_id,
          user_name: log.user_name,
          action: log.action,
          auditable_type: log.auditable_type,
          auditable_id: log.auditable_id,
          auditable_name: log.auditable_name,
          summary: log.summary,
          created_at: log.created_at
        }

        if detailed
          response.merge!({
                            changes: log.changes,
                            ip_address: log.ip_address,
                            user_agent: log.user_agent
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
