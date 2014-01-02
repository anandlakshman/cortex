class TenantsController < ApplicationController
  before_action :set_tenant, only: [:show, :update, :destroy]
  respond_to :json

  # GET /tenants
  def index
    @tenants = Tenant.all
  end

  # GET /tenants/hierarchy
  def hierarchy
    @tenants = Tenant.roots
  end

  # GET /organizations/:org_id/tenants
  def by_organization
    @tenants = params[:include_root] ? [Tenant.find(params[:org_id])] : Tenant.find(params[:org_id]).children
    render :index
  end

  # GET /organizations/:org_id/tenants/hierarchy
  def hierarchy_by_organization
    @tenants = params[:include_root] ? [Tenant.find(params[:org_id])] : Tenant.find(params[:org_id]).children
    render :hierarchy
  end

  # GET /tenants/1
  def show
    respond_with @tenant
  end

  # POST /tenants
  def create
    @tenant = Tenant.new(tenant_params)
    @tenant.user = @current_user
    @tenant.save!
    respond_with @tenant
  end

  # PATCH/PUT /tenants/1
  def update
    respond_with @tenant.update(tenant_params)
  end

  # DELETE /tenants/1
  def destroy
    @tenant.update(deleted_at: Time.now.utc)
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tenant
      @tenant = Tenant.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tenant_params
      params.require(:tenant).permit(:name, :parent_id, :contact_name, :contact_email, :contact_phone, :active_at, :deactive_at, :contract, :did, :subdomain)
    end
end
