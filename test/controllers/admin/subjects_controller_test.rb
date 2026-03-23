require "test_helper"

class Admin::SubjectsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @owner_user = users(:one)
    @regular_user = users(:two)
    @subject = subjects(:mycology)
  end

  test "admin can list subjects" do
    sign_in @owner_user
    get admin_subjects_url
    assert_response :success
    assert_includes response.body, @subject.name
  end

  test "admin can create subject" do
    sign_in @owner_user

    assert_difference("Subject.count", 1) do
      post admin_subjects_url, params: {
        subject: {
          name: "Ecology"
        }
      }
    end

    created = Subject.last
    assert_redirected_to admin_subject_url(created)
    assert_equal "ecology", created.slug
  end

  test "admin can update subject" do
    sign_in @owner_user

    patch admin_subject_url(@subject), params: {
      subject: { name: "Updated Subject Name" }
    }

    assert_redirected_to admin_subject_url(@subject)
    assert_equal "Updated Subject Name", @subject.reload.name
    assert_equal "mycology", @subject.slug
  end

  test "admin can destroy subject" do
    sign_in @owner_user
    subject = Subject.create!(name: "Disposable Subject")

    assert_difference("Subject.count", -1) do
      delete admin_subject_url(subject)
    end

    assert_redirected_to admin_subjects_url
  end

  test "non-admin cannot access subjects" do
    sign_in @regular_user
    get admin_subjects_url

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this area.", flash[:alert]
  end
end
