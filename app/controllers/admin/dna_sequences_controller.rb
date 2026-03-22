class Admin::DnaSequencesController < Admin::ApplicationController
  before_action :set_dna_sequence, only: %i[show edit update destroy]

  # GET /dna_sequences
  def index
    authorize DnaSequence
    @dna_sequences = policy_scope(DnaSequence.includes(:mushroom).order(created_at: :desc))
  end

  # GET /dna_sequences/1
  def show
    authorize @dna_sequence
  end

  # GET /dna_sequences/new
  def new
    @dna_sequence = DnaSequence.new
    authorize @dna_sequence
  end

  # POST /dna_sequences
  def create
    @dna_sequence = DnaSequence.new(dna_sequence_params)
    authorize @dna_sequence
    if @dna_sequence.save
      redirect_to admin_dna_sequence_path(@dna_sequence), notice: "DNA sequence was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /dna_sequences/1/edit
  def edit
    authorize @dna_sequence
  end

  # PATCH/PUT /dna_sequences/1
  def update
    authorize @dna_sequence
    if @dna_sequence.update(dna_sequence_params)
      redirect_to admin_dna_sequence_path(@dna_sequence), notice: "DNA sequence was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /dna_sequences/1
  def destroy
    authorize @dna_sequence
    @dna_sequence.destroy!
    redirect_to admin_dna_sequences_path, notice: "DNA sequence was successfully deleted."
  end

  private

  def set_dna_sequence
    @dna_sequence = DnaSequence.find(params.expect(:id))
  end

  def dna_sequence_params
    params.expect(dna_sequence: [
      :mushroom_id, :notes, :dna_barcode_its, :genbank_number_url,
      :genbank_accession_number, :herbarium_catalog_number,
      :mycomap_blast_results, :provisional_species_name,
      :sequencing_technology, :trace_files_raw_dna_data, :voucher_number
    ])
  end
end