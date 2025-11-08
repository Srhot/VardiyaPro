# frozen_string_literal: true

module Api
  module V1
    class NotificationsController < BaseController
      before_action :authenticate_request
      before_action :set_notification, only: %i[show mark_as_read destroy]

      # GET /api/v1/notifications
      # List user's notifications
      def index
        notifications = current_user.notifications.recent

        # Optional filters
        notifications = notifications.unread if params[:unread] == 'true'
        notifications = notifications.by_type(params[:type]) if params[:type].present?

        # Pagination
        page = params[:page] || 1
        per_page = params[:per_page] || 25
        notifications = notifications.page(page).per(per_page)

        render json: {
          data: notifications.map { |notification| notification_response(notification) },
          meta: pagination_meta(notifications),
          unread_count: current_user.notifications.unread.count
        }, status: :ok
      end

      # GET /api/v1/notifications/:id
      # Show notification details
      def show
        render json: {
          data: notification_response(@notification, detailed: true)
        }, status: :ok
      end

      # PATCH /api/v1/notifications/:id/mark_as_read
      # Mark single notification as read
      def mark_as_read
        if @notification.mark_as_read!
          render json: {
            data: notification_response(@notification),
            message: 'Notification marked as read'
          }, status: :ok
        else
          render json: {
            errors: @notification.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # PATCH /api/v1/notifications/mark_all_as_read
      # Mark all user's notifications as read
      def mark_all_as_read
        count = Notification.mark_all_as_read(current_user.id)
        render json: {
          message: "#{count} notifications marked as read",
          unread_count: current_user.notifications.unread.count
        }, status: :ok
      end

      # DELETE /api/v1/notifications/:id
      # Delete notification
      def destroy
        if @notification.destroy
          render json: {
            message: 'Notification deleted successfully'
          }, status: :ok
        else
          render json: {
            errors: @notification.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/notifications/destroy_all_read
      # Delete all read notifications
      def destroy_all_read
        count = current_user.notifications.read.destroy_all.count
        render json: {
          message: "#{count} read notifications deleted"
        }, status: :ok
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end

      def notification_response(notification, detailed: false)
        response = {
          id: notification.id,
          title: notification.title,
          message: notification.message,
          notification_type: notification.notification_type,
          read: notification.read,
          created_at: notification.created_at
        }

        if detailed
          response.merge!({
                            related_type: notification.related_type,
                            related_id: notification.related_id,
                            updated_at: notification.updated_at
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
