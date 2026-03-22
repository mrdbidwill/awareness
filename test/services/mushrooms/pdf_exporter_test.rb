require "test_helper"

class Mushrooms::PdfExporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @mushroom = mushrooms(:one)
    @other_mushroom = mushrooms(:three)
  end

  test "exports all user mushrooms when no ids provided" do
    result = with_pdf_service do
      with_pundit_authorize do
        Mushrooms::PdfExporter.call(user: @user)
      end
    end

    assert result.success?
    assert_equal "all-mushrooms-#{Date.today}.pdf", result.data[:filename]
    assert_equal "PDFDATA", result.data[:pdf]
  end

  test "exports a single mushroom with name-based filename" do
    result = with_pdf_service do
      with_pundit_authorize do
        Mushrooms::PdfExporter.call(user: @user, mushroom_ids: [@mushroom.id])
      end
    end

    expected = "#{@mushroom.name.parameterize}-#{Date.today}.pdf"
    assert result.success?
    assert_equal expected, result.data[:filename]
  end

  test "exports multiple mushrooms with generic filename" do
    result = with_pdf_service do
      with_pundit_authorize do
        Mushrooms::PdfExporter.call(user: @user, mushroom_ids: [@mushroom.id, @other_mushroom.id])
      end
    end

    assert result.success?
    assert_equal "mushrooms-export-#{Date.today}.pdf", result.data[:filename]
  end

  test "returns failure when mushroom is not found" do
    result = with_pdf_service do
      with_pundit_authorize do
        Mushrooms::PdfExporter.call(user: @user, mushroom_ids: ["999999"])
      end
    end

    assert result.failure?
    assert_equal "Mushroom not found", result.error
  end

  test "raises when not authorized" do
    assert_raises(Pundit::NotAuthorizedError) do
      with_pdf_service do
        with_pundit_authorize(error: Pundit::NotAuthorizedError.new) do
          Mushrooms::PdfExporter.call(user: @user, mushroom_ids: [@mushroom.id])
        end
      end
    end
  end

  private

  def with_pdf_service
    fake_pdf = Struct.new(:data) do
      def render
        data
      end
    end.new("PDFDATA")

    fake_service = Struct.new(:pdf) do
      def generate
        pdf
      end
    end.new(fake_pdf)

    original_new = MushroomPdfService.method(:new)
    MushroomPdfService.define_singleton_method(:new) { |_mushrooms| fake_service }

    yield
  ensure
    MushroomPdfService.define_singleton_method(:new) { |*args| original_new.call(*args) } if original_new
  end

  def with_pundit_authorize(error: nil)
    original_authorize = Pundit.method(:authorize)

    if error
      Pundit.define_singleton_method(:authorize) { |_user, _record, _query| raise error }
    else
      Pundit.define_singleton_method(:authorize) { |_user, _record, _query| true }
    end

    yield
  ensure
    Pundit.define_singleton_method(:authorize) { |*args| original_authorize.call(*args) } if original_authorize
  end
end
