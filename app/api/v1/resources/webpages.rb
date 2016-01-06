require_relative '../helpers/resource_helper'
require 'uri'

module API
  module V1
    module Resources
      class Webpages < Grape::API
        helpers Helpers::SharedParams

        resource :webpages do
          include Grape::Kaminari
          helpers Helpers::WebpagesHelper
          paginate per_page: 25

          desc 'Show all webpages', { entity: Entities::Webpage, nickname: 'showAllWebpages' }
          get do
            authorize! :view, ::Webpage
            require_scope! :'view:webpages'

            @webpages = ::GetWebpages.call(params: declared(webpage_params, include_missing: false), tenant: current_tenant.id).webpages
            Entities::Webpage.represent paginate(@webpages), full: true
          end

          desc 'Show Webpage Snippets as public feed by URL', { entity: Entities::Webpage, nickname: 'showWebpageFeed' }
          params do
            requires :url, type: String
          end
          get 'feed' do
            require_scope! :'view:webpages'
            @webpage ||= Webpage.find_by_url(params[:url])
            not_found! unless @webpage
            authorize! :view, @webpage
            present @webpage, with: Entities::Webpage
          end

          desc 'Get webpage', { entity: Entities::Webpage, nickname: 'showWebpage' }
          get ':id' do
            require_scope! :'view:webpages'
            authorize! :view, webpage!

            present webpage, with: Entities::Webpage, full: true
          end

          desc 'Create webpage', { entity: Entities::Webpage, params: Entities::Webpage.documentation, nickname: 'createWebpage' }
          post do
            require_scope! :'modify:webpages'
            authorize! :create, ::Webpage

            webpage_params = params[:webpage] || params

            @webpage = ::Webpage.new(declared(webpage_params, { include_missing: false }, Entities::Webpage.documentation.keys))
            webpage.user = current_user!
            webpage.save!

            present webpage, with: Entities::Webpage, full: true
          end

          desc 'Update webpage', { entity: Entities::Webpage, params: Entities::Webpage.documentation, nickname: 'updateWebpage' }
          put ':id' do
            require_scope! :'modify:webpages'
            authorize! :update, webpage!

            webpage_params = params[:webpage] || params
            allowed_params = remove_params(Entities::Webpage.documentation.keys, :user) + [:snippets_attributes]
            update_params = declared(webpage_params, { include_missing: false }, allowed_params)
            update_params[:snippets_attributes].each {|snippet|
              snippet.user = current_user!
              snippet[:document_attributes].user = current_user!
            }

            webpage.update!(update_params.to_hash)

            # HTTP request to application to clear cache
            root_domain_uri = URI.parse(webpage.url)
            cache_buster_url = root_domain_uri.scheme + "://" + root_domain_uri.host + "/cache" + URI.encode(root_domain_uri.path)
            Excon.delete cache_buster_url

            present webpage, with: Entities::Webpage, full: true
          end

          desc 'Delete webpage', { nickname: 'deleteWebpage' }
          delete ':id' do
            require_scope! :'modify:webpages'
            authorize! :delete, webpage!

            begin
              webpage.destroy
            rescue Cortex::Exceptions::ResourceConsumed => e
              error = error!({
                               error:   'Conflict',
                               message: e.message,
                               status:  409
                             }, 409)
              error
            end
          end
        end
      end
    end
  end
end
