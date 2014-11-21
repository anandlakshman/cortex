module API
  module V1
    module Helpers
      module JargonHelper
        def jargon
          @jargon ||= Jargon::Client.new(key: Cortex.config.jargon.client_id,
                                         secret: Cortex.config.jargon.client_secret,
                                         base_url: Cortex.config.jargon.site_url)
        end

        def merge_localizations(cortex_localizations, jargon_localizations)
          cortex_localizations.map { |cortex_localization|
            jargon_localization = jargon_localizations.select { |jargon_localization| jargon_localization.id == cortex_localization.jargon_id }.first
            merge_localization(cortex_localization, jargon_localization)
          }
        end

        def merge_localization(cortex_localization, jargon_localization)
          jargon_localization.id = cortex_localization.id
          jargon_localization.user = cortex_localization.user
          jargon_localization.locales = jargon_localization.locales.map { |jargon_locale|
            cortex_locale = cortex_localization.select { |cortex_locale| cortex_locale.name == jargon_locale.name }.first
            merge_locale(cortex_locale, jargon_locale)
          }

          jargon_localization
        end

        def merge_locales(cortex_locales, jargon_locales)
          
        end

        def merge_locale(cortex_locale, jargon_locale)
          jargon_locale.id = cortex_locale.id
          jargon_locale.user = cortex_locale.user

          jargon_locale
        end

        def expects_id!
          if !id
            raise Cortex::Exceptions::IdExpected
          end
        end

        def rejects_id!
          if id
            raise Cortex::Exceptions::IdNotExpected
          end
        end
      end
    end
  end
end
