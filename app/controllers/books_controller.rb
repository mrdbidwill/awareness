# frozen_string_literal: true

class BooksController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_policy_scoped, only: :index, raise: false

  def index
    @books = [
      {
        title: "Amanita Muscaria: Ecology, Ritual, and Interpretation",
        author: "Robert Gordon Wasson",
        format: "Book",
        notes: "Classic historical and ethnomycology reference."
      },
      {
        title: "Mushrooms Demystified",
        author: "David Arora",
        format: "Book",
        notes: "Field-focused reference for North American mushrooms."
      },
      {
        title: "Radical Mycology",
        author: "Peter McCoy",
        format: "Book",
        notes: "Community mycology, cultivation, and ecological applications."
      }
    ]
  end
end
