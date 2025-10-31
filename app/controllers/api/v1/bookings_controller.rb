# frozen_string_literal: true

module Api
  module V1
    class BookingsController < BaseController
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from BookingManager::Error, with: :render_service_error

      def create
        session = Session.find(booking_params[:session_id])
        result = BookingManager.new(user: current_user, session: session).book

        if result.waitlisted
          render json: {
            status: 'waitlisted',
            waitlist_position: result.waitlist_entry.position
          }, status: :accepted
        else
          render json: booking_payload(result.booking), status: :created
        end
      end

      def destroy
        booking = current_user.bookings.find(params[:id])
        BookingManager.new(user: current_user, session: booking.session).cancel(
          booking: booking,
          canceled_at: Time.current,
          no_show: ActiveModel::Type::Boolean.new.cast(params[:no_show])
        )

        render json: { status: 'canceled' }, status: :ok
      end

      private

      def booking_params
        params.require(:booking).permit(:session_id)
      end

      def booking_payload(booking)
        {
          id: booking.id,
          session_id: booking.session_id,
          status: booking.status,
          used_credits: booking.used_credits,
          subscription_plan_id: booking.subscription_plan_id
        }
      end

      def render_not_found
        render_error('Record not found', :not_found)
      end

      def render_service_error(exception)
        render_error(exception.message)
      end
    end
  end
end
