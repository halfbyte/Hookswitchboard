class Incoming

  class IllegalProcessingInstruction < RuntimeError ; end
  class NotImplementedProcessingInstruction < RuntimeError ; end

  include MongoMapper::Document

  key :source, String
  key :params, Hash
  key :post_body, String

  key :variables, Hash
  
  key :discarded_at, Time

  timestamps!

  INSTRUCTION_SET = [:parse_json, :if, :send_post, :discard]


  INSTRUCTIONS = [
    {'parse_json' => 'params.data'},
    {'if' => [
      {'variables.build.phase' => 'FINISHED'}, [
        {'if' => [
          {'variables.build.status' => 'SUCCESS'},
          [
            {'send_post' => 'http://localhost:4567/stop/red'}
          ],
          [
            {'send_post' => 'http://localhost:4567/start/red'}
          ]
        ]}
      ],
      [
        { 'discard' => true }
      ]
    ]}
  ]
  
  def hash_access(selector)
    parts = selector.split(".")
    elem = send(parts.shift.to_sym)
    parts.each do |p|
      elem = elem[p]
    end
    elem
  end

  def parse_json(i)
    self.variables = JSON.parse(hash_access(i))
  end
  
  def if(i)
    test, do_if, do_else = i
    key = test.keys.first
    test_result = hash_access(key).to_s == test[key].to_s
    instr = test_result ? do_if : do_else    
    instr.each do |ins|
      process_instruction(ins)
    end      
  end
  
  def send_post(i)
    HTTPI.post(i, "")
  end
  
  def discard(i)
    self.discarded_at = Time.now
  end
  
  
  def process_instruction(instruction)
    cmd = instruction.keys.first.to_sym
    puts cmd
    if INSTRUCTION_SET.include?(cmd)
      if respond_to?(cmd)
        send(cmd, instruction[cmd.to_s])
      else
        raise NotImplementedProcessingInstruction, cmd
      end
    else
      raise IllegalProcessingInstruction, cmd
    end      
  end
  
  def process    
    INSTRUCTIONS.each do |instruction|
      process_instruction(instruction)
    end
  end

end
