# frozen_string_literal: true

class BooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  def index
    @source_data = SourceData
      .includes(:source_data_type)
      .where(source_data_type_id: [1, 4, 8, 9]) # 1 = book, 4 = chart, 8 = kindle, 9 = e book
      .order(:title)
  end
end
