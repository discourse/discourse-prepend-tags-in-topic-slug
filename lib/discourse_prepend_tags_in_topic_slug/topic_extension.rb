# frozen_string_literal: true

module DiscoursePrependTagsInTopicSlug::TopicExtension
  prepend_tags_into_slug = ->(topic, slug, title) do
    targeted_tags = SiteSetting.prepend_tags_in_topic_slug_tag_list.split("|")

    selected_tags = topic.tags.map(&:name).select { |tag| targeted_tags.include?(tag) }.sort

    if !selected_tags.empty?
      Slug.for("#{selected_tags.join(" ")} #{title}")
    else
      slug
    end
  end

  # hook the lambda in core to change how the slugs are generated
  Topic.slug_computed_callbacks << prepend_tags_into_slug
end
