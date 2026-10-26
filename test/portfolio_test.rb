require "minitest/autorun"

class PortfolioTest < Minitest::Test
  def setup
    @page = File.read(File.expand_path("../index.md", __dir__))
    @layout = File.read(File.expand_path("../_layouts/portfolio.html", __dir__))
    @styles = File.read(File.expand_path("../media/portfolio.css", __dir__))
    @not_found = File.read(File.expand_path("../404.md", __dir__))
  end

  def test_main_sections_are_present
    %w[about experience skills education contact].each do |section_id|
      assert_match(/id="#{section_id}"/, @page)
    end
  end

  def test_education_section_is_present
    assert_includes @page, "BSc Computing and IT (in Progress)"
    assert_includes @page, "The Open University"
  end

  def test_experience_matches_the_latest_cv
    assert_includes @page, "Senior Software Developer · Trade Republic Bank"
    assert_includes @page, "Aug 2024 — Dec 2024"
    assert_includes @page, "settlement instructions"
    assert_includes @page, "Börse Stuttgart Digital"
  end

  def test_skills_and_languages_match_the_latest_cv
    assert_includes @page, "Kotlin"
    assert_includes @page, "Python, Go, C#"
    assert_includes @page, "German (native), English (fluent)"
    refute_includes @page, "Clojure"
  end

  def test_navigation_links_have_matching_sections
    template = @layout + @page
    local_links = template.scan(/href="#([^"]+)"/).flatten
    root_links = @layout.scan(/relative_url }}#([^"]+)/).flatten
    links = local_links + root_links
    section_ids = template.scan(/\bid="([^"]+)"/).flatten

    assert_empty links - section_ids
  end

  def test_cv_download_links_to_the_repository_cv
    assert_match(%r{'/docs/CV_EN\.pdf' \| relative_url}, @page)
    assert File.file?(File.expand_path("../docs/CV_EN.pdf", __dir__))
  end

  def test_about_section_shows_the_portrait
    assert_match(%r{<img src="\{\{ '/media/Photo_Portrait\.jpg' \| relative_url \}\}" alt="Portrait of Giuliano Di Pasquale"}, @page)
    assert File.file?(File.expand_path("../media/Photo_Portrait.jpg", __dir__))
    assert_includes @styles, ".about__portrait img"
  end

  def test_styles_support_small_screens_and_reduced_motion
    assert_includes @styles, "@media (max-width: 700px)"
    assert_includes @styles, "@media (prefers-reduced-motion: reduce)"
  end

  def test_not_found_page_uses_portfolio_layout
    assert_match(/^layout: portfolio$/, @not_found)
    assert_includes @not_found, "{{ '/' | relative_url }}"
  end
end
