module V1
  module Helpers
    module LocaleHelper
      def locale
        @locale ||= ::Localization.find_by_id(params[:id]).retrieve_locale(params[:locale_name])
      end

      def locale!
        locale || not_found!
      end
    end
  end
end