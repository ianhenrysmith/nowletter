class Message
  attr_accessor :body, :phone_number, :opcode, :operand

  OPERATION_MAPPINGS = {
    "new" => :create,
    "send" => :send,
    "sub" => :subscribe,
    "unsub" => :unsubscribe,
    "help" => :help
  }

  def self.from_twilio(attributes)
    message = self.new
    message.body = attributes[:Body]
    message.phone_number = attributes[:From]

    message.opcode, message.operand = message.body.downcase.split(" ", 2)

    message
  end

  def operation
    OPERATION_MAPPINGS[opcode]
  end

  def shortcode
    # usually a Newsletter id (gonna add slugs at some point)
    operand.split(" ")[0]
  end
end