class InaturalistDataController < ApplicationController
  skip_after_action :verify_policy_scoped, only: [:index], raise: false
  skip_after_action :verify_authorized, only: [:download_csv, :download_json], raise: false

  def index
    @query = params[:q]
    @exact_only = params[:exact_only] == '1'
    @observation_fields = InaturalistObservationField.all

    # Apply search if query present and exact-only is not enabled
    @observation_fields = @observation_fields.search(@query) if @query.present? && !@exact_only

    # Optional exact match filter
    @observation_fields = @observation_fields.canonical if @exact_only

    # Order and paginate
    @observation_fields = @observation_fields.canonical_first.page(params[:page]).per(50)
    @total_count = InaturalistObservationField.count
  end

  def download_csv
    require 'csv'

    csv_path = Rails.root.join('data', 'inaturalist', 'observation_fields.csv')
    tmp_path = Rails.root.join('tmp', 'inaturalist_observation_fields.csv')
    file_path = [csv_path, tmp_path].find { |path| File.exist?(path) && File.readable?(path) }

    if file_path
      send_file file_path,
                filename: 'inaturalist_observation_fields.csv',
                type: 'text/csv',
                disposition: 'attachment'
      return
    end

    observation_fields = InaturalistObservationField.all
    if observation_fields.exists?
      csv_data = CSV.generate(headers: true) do |csv|
        csv << ['id', 'name', 'datatype', 'user_id', 'description', 'created_at',
                'updated_at', 'allowed_values', 'values_count', 'users_count', 'uuid']

        observation_fields.find_each do |field|
          csv << [
            field.inaturalist_id,
            field.name,
            field.datatype,
            field.user_id,
            field.description,
            field.created_at,
            field.updated_at,
            field.allowed_values,
            field.values_count,
            field.users_count,
            field.uuid
          ]
        end
      end

      send_data csv_data,
                filename: 'inaturalist_observation_fields.csv',
                type: 'text/csv',
                disposition: 'attachment'
    else
      redirect_to inaturalist_observation_fields_path, alert: "CSV file not found"
    end
  end

  def download_json
    # Generate JSON from database
    @observation_fields = InaturalistObservationField.all
    json_data = @observation_fields.as_json(except: [:id, :created_at, :updated_at])

    send_data json_data.to_json,
              filename: 'inaturalist_observation_fields.json',
              type: 'application/json',
              disposition: 'attachment'
  end
end
