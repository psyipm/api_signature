# frozen_string_literal: true

module ApiSignature
  module SpecSupport
    class PathBuilder
      attr_reader :controller, :action_name, :params

      PRIMARY_KEYS = [:id, :token].freeze

      def initialize(controller, action_name, params = {})
        @controller = controller
        @action_name = action_name
        @params = params
      end

      def path
        if params[:path].present?
          hash = params.delete(:path)
          url_options.merge!(hash)
          params.merge!(hash)
        end

        controller.url_for(url_options)
      end

      private

      def url_options
        @url_options ||= {
          action: action_name,
          controller: controller.controller_path,
          only_path: true
        }.merge(key_options || {})
      end

      def key_options
        key = (params.keys.map(&:to_sym) & PRIMARY_KEYS).first
        { key => params[key] } if params[key].present?
      end
    end
  end
end
