# frozen_string_literal: true

# name: discourse-prepend-tags-in-topic-slug
# about: A small plugin to prepend the name of some tags to the topic slugs
# version: 0.0.1
# authors: Discourse
# url: https://github.com/discourse/discourse-prepend-tags-in-topic-slug
# required_version: 2.7.0

enabled_site_setting :prepend_tags_in_topic_slug_enabled

after_initialize do
  module ::DiscoursePrependTagsInTopicSlug
    PLUGIN_NAME ||= "discourse-prepend-tags-in-topic-slug".freeze

    class Engine < ::Rails::Engine
      engine_name DiscoursePrependTagsInTopicSlug::PLUGIN_NAME
      isolate_namespace DiscoursePrependTagsInTopicSlug
    end
  end

  module DiscoursePrependTagsInTopicSlug
    require_relative "lib/discourse_prepend_tags_in_topic_slug/topic_extension"
  end

  on(:topic_tags_changed) do |topic|
    # added space in the end of the title will force the update of the slug
    topic.title << " "
  end
end
