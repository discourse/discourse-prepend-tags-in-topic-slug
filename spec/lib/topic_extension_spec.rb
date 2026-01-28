# frozen_string_literal: true

describe DiscoursePrependTagsInTopicSlug::TopicExtension do
  before { SiteSetting.prepend_tags_in_topic_slug_tag_list = "tag1|tag2" }

  fab!(:tag1) { Fabricate(:tag, name: "tag1") }
  fab!(:tag2) { Fabricate(:tag, name: "tag2") }
  fab!(:tag3) { Fabricate(:tag, name: "tag3") }
  fab!(:tag4) { Fabricate(:tag, name: "tag4") }

  context "when creating new topics" do
    let(:target_tag_topic) { Fabricate(:topic, title: "this is a test topic", tags: [tag1]) }
    let(:multiple_target_tag_topic) do
      Fabricate(:topic, title: "this is a test topic", tags: [tag2, tag1])
    end
    let(:mixed_tag_topic) { Fabricate(:topic, title: "this is a test topic", tags: [tag1, tag3]) }
    let(:unmatched_tag_topic) do
      Fabricate(:topic, title: "this is a test topic", tags: [tag3, tag4])
    end
    let(:untagged_topic) { Fabricate(:topic, title: "this is a test topic") }

    it "prepends the tag to the slug when the topic is created with a target tag" do
      expect(target_tag_topic.slug).to eq("tag1-this-is-a-test-topic")
    end

    it "prepends the matched tags in alphabetical order to the slug when the topic is created with targeted tags" do
      expect(multiple_target_tag_topic.slug).to eq("tag1-tag2-this-is-a-test-topic")
    end

    it "prepends only the configured tags to the slug when the topic is created with a target tag" do
      expect(mixed_tag_topic.slug).to eq("tag1-this-is-a-test-topic")
    end

    it "generates the default slug when the topic is untagged" do
      expect(untagged_topic.slug).to eq("this-is-a-test-topic")
    end

    it "generates the default slug when the topic tags does not match the configured tags" do
      expect(unmatched_tag_topic.slug).to eq("this-is-a-test-topic")
    end
  end

  context "when editing existing topics" do
    let(:topic) { Fabricate(:topic, title: "this is a test topic", tags: [tag2]) }

    it "correctly updates the slug when a target tag is added" do
      expect(topic.slug).to eq("tag2-this-is-a-test-topic")
      topic.tags = [tag1, tag2]
      topic.save
      expect(topic.slug).to eq("tag1-tag2-this-is-a-test-topic")
    end

    it "correctly updates the slug when a target tag is replaced" do
      expect(topic.slug).to eq("tag2-this-is-a-test-topic")
      topic.tags = [tag1]
      topic.save
      expect(topic.slug).to eq("tag1-this-is-a-test-topic")
    end

    it "correctly updates the slug when a target tag is removed" do
      expect(topic.slug).to eq("tag2-this-is-a-test-topic")
      topic.tags = []
      topic.save
      expect(topic.slug).to eq("this-is-a-test-topic")
    end

    it "correctly updates the slug when a target tag is replace by a non-target" do
      expect(topic.slug).to eq("tag2-this-is-a-test-topic")
      topic.tags = [tag3]
      topic.save
      expect(topic.slug).to eq("this-is-a-test-topic")
    end

    it "correctly updates the slug when the title is updated" do
      expect(topic.slug).to eq("tag2-this-is-a-test-topic")
      topic.title = "this is a new topic title"
      topic.save
      expect(topic.slug).to eq("tag2-this-is-a-new-topic-title")
    end
  end
end
