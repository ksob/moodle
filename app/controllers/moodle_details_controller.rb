class MoodleDetailsController < ApplicationController
  before_action :set_moodle_detail, only: [:show, :edit, :update, :destroy]

  # GET /moodle_details
  # GET /moodle_details.json
  def index
    @moodle_details = MoodleDetail.all
  end

  # GET /moodle_details/1
  # GET /moodle_details/1.json
  def show
  end

  # GET /moodle_details/new
  def new
    @moodle_detail = MoodleDetail.new
  end

  # GET /moodle_details/1/edit
  def edit
  end

  # POST /moodle_details
  # POST /moodle_details.json
  def create
    @moodle_detail = MoodleDetail.new(moodle_detail_params)

    respond_to do |format|
      if @moodle_detail.save
        format.html { redirect_to root_path, notice: 'Zapisano.' }
        format.json { render :show, status: :created, location: @moodle_detail }
      else
        format.html {  render :template => "home/index" }
        format.json { render json: @moodle_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /moodle_details/1
  # PATCH/PUT /moodle_details/1.json
  def update
    respond_to do |format|
      if @moodle_detail.update(moodle_detail_params)
        format.html { redirect_to root_path, notice: 'Dane zaktualizowano.' }
        format.json { render :show, status: :ok, location: @moodle_detail }
      else
        format.html {  render :template => "home/index" }
        format.json { render json: @moodle_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /moodle_details/1
  # DELETE /moodle_details/1.json
  def destroy
    @moodle_detail.destroy
    respond_to do |format|
      format.html { redirect_to moodle_details_url, notice: 'Moodle detail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_moodle_detail
    @moodle_detail = MoodleDetail.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def moodle_detail_params
    params.require(:moodle_detail).permit(:host, :token, :user_id)
  end
end
