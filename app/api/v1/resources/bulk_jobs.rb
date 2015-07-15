require_relative '../helpers/resource_helper'

module API
  module V1
    module Resources
      class BulkJobs < Grape::API
        helpers Helpers::SharedParams

        resource :bulk_jobs do
          helpers Helpers::PaginationHelper
          helpers Helpers::BulkJobsHelper

          desc 'Show all bulk jobs', { entity: Entities::BulkJob, nickname: 'showAllBulkJobs' }
          params do
            use :pagination
          end
          get do
            authorize! :view, ::BulkJob
            require_scope! :'view:bulk_jobs'

            @bulk_job = ::BulkJob.order(created_at: :desc).page(page).per(per_page)
            set_pagination_headers(@bulk_job, 'bulk_job')

            present @bulk_job, with: Entities::BulkJob
          end

          desc 'Get bulk job', { entity: Entities::BulkJob, nickname: 'showBulkJob' }
          get ':id' do
            require_scope! :'view:bulk_jobs'
            authorize! :view, bulk_job!

            present bulk_job, with: Entities::BulkJob
          end
        end
      end
    end
  end
end