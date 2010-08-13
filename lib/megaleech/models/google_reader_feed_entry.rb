module Megaleech
  class GoogleReader
    class FeedEntry
      attr_reader :data

      def initialize(entry_node)
        @data = entry_node
      end

      def id
        content(attribute(node("id"), "original-id"))
      end

      def updated
        Time.parse(content(node("updated")))
      end

      def enclosure
        content(attribute(node("link", {:rel => "enclosure"}), "href"))
      end

      def title
        content(node("title"))
      end

      def summary
        content(node("summary"))
      end

      def source
        content(node("source/xmlns:title"))
      end

      def source_link
        content(attribute(node("source/xmlns:link"), "href"))
      end

      def source_id
        content(node("source/xmlns:id"))
      end


      private

      def content(node)
        node.content.strip if node
      end

      def attribute(node, attribute)
        node.attribute(attribute) if node
      end

      def node(tag, attributes = {})
        attribute_filter = attributes.map { |k, v| "@#{k}='#{v}'" }
        if attribute_filter.empty?
          @data.at_xpath("./xmlns:#{tag}")
        else
          @data.at_xpath("./xmlns:#{tag}[#{attribute_filter.join(" and ")}]")
        end
      end

    end
  end
end