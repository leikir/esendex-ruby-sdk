require 'nokogiri'

#<messages>
#  <accountreference>EX000000</accountreference>
#  <message>
#    <to>someone</to>
#    <body>$BODY</body>
#  </message>
#  <message>
#    <to>$TO_</to>
#    <body>$BODY</body>
#  </message>
#</messages>

module Esendex
  class MessageBatchSubmission
    attr_accessor :account_reference, :messages, :send_at, :character_set
    
    def initialize(account_reference, messages, send_at=nil, character_set="Auto")
      raise AccountReferenceError unless account_reference
      raise StandardError, "Need at least one message" unless messages.kind_of?(Array) && !messages.empty?

      @account_reference = account_reference
      @messages = messages
      @send_at = send_at
      @character_set = character_set
    end
    
    def xml_node
      doc = Nokogiri::XML'<messages/>'
                  
      account_reference = Nokogiri::XML::Node.new 'accountreference', doc
      account_reference.content = self.account_reference
      doc.root.add_child(account_reference)

      character_set = Nokogiri::XML::Node.new 'characterset', doc
      character_set.content = self.character_set
      doc.root.add_child(character_set)

      if @send_at.present?
        send_at_node = Nokogiri::XML::Node.new 'sendat', doc
        send_at_node.content = @send_at.strftime("%Y-%m-%dT%H:%M:%S%Z")
        doc.root.add_child(send_at_node)
      end
      
      @messages.each do |message|
        doc.root.add_child(message.xml_node)
      end
      
      doc.root
    end
    
    def to_s
      xml_node.to_s
    end
  end
end