class ZonesController < ApplicationController
  before_action :set_zone, only: [:show, :edit, :update, :destroy]
  before_action :use_gmaps, only: [:index]

  # GET /zones
  # GET /zones.json
  def index
    @zones = Zone.all
    zones_for_json = []
    # The zone model has id, name, and coords.  But PolygonManager expects any data other than id and coords
    # to be in a property called meta in the json object.  So, we need to make a new array that has the zones
    # in this format.  The following loop creates that array.
    @zones.each do |zone|
      # Create a new hash to represent this zone.  For now, we include, the id, any data we want in meta (in
      # this case we just need the name), and set coords as an empty array that we can add coordinate hashes to
      zone_obj = {id: zone.id, meta: {name: zone.name}, coords: []}

      # Here we loop through the coordinates for this zone and add a hash with the keys lat and lng for each
      # coordinate to the zone's coords key that we previously set as an empty array
      zone.coords.each do |coord|
        zone_obj[:coords] << {lat: coord.lat, lng: coord.lng}
      end

      # Add this new zone object to the zones_for_json array
      zones_for_json << zone_obj
    end

    # Now we convert that array to json:
    @zones_json = zones_for_json.to_json
  end

  # GET /zones/1
  # GET /zones/1.json
  def show
  end

  # GET /zones/new
  def new
    @zone = Zone.new
  end

  # GET /zones/1/edit
  def edit
  end

  # POST /zones
  # POST /zones.json
  def create
    @zone = Zone.new(zone_params)

    respond_to do |format|
      if @zone.save
        format.html { redirect_to @zone, notice: 'Zone was successfully created.' }
        format.json { render :show, status: :created, location: @zone }
        format.js
      else
        format.html { render :new }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /zones/1
  # PATCH/PUT /zones/1.json
  def update
    @zone.coords.delete_all
    respond_to do |format|
      if @zone.update(zone_params)
        format.html { redirect_to @zone, notice: 'Zone was successfully updated.' }
        format.json { render :show, status: :ok, location: @zone }
        format.js
      else
        format.html { render :edit }
        format.json { render json: @zone.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # DELETE /zones/1
  # DELETE /zones/1.json
  def destroy
    @zone.destroy
    respond_to do |format|
      format.html { redirect_to zones_url, notice: 'Zone was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_zone
      @zone = Zone.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def zone_params
      params.require(:zone).permit(:name, coords_attributes:  [:lat, :lng])
    end
end
