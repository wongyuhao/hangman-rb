require_relative "BasicSerializable"
require 'date'

class Game 
include BasicSerializable
  MAX_ATTEMPTS=6
  attr_accessor :answer,:holder,:wrong, :attempts
  def initialize 
    @answer= "hello"
    @holder =""
    @wrong =[]
    @attempts =0
    
    @answer.length.times do 
      @holder +="_"
    end
  end

  def loadWord
    lines = File.readlines '5desk.txt'
    lines.map!{|word| word.gsub!("\r\n","") }
    lines.reject!{|word| (word.length>12 || word.length<5)} 
    word = lines[rand(lines.length)]
    puts "debug: chosen word is #{word}"
    word
  end

  def start
    
    while @attempts < MAX_ATTEMPTS do
      
      display
      puts "Wrong guesses: #{@wrong.join(",")}" unless @wrong.size==0
      puts "#{MAX_ATTEMPTS-@attempts} Attemps remaining."
      
      while true
        print "Enter your guess (type 'save' to save the game): "
        
        input = gets.chomp
        if (!input.match(/^[A-Za-z]+$/))
          puts "Enter a valid letter!"
        end
        
        if input.length==1
          evaluate(input) 
          break
        elsif input == 'save'
          save
        else
          puts "You can only guess one character at a time!"
        end
      
         
      end
      @attempts+=1
      if !@holder.include?("_")
        puts "YOU WIN"
        break
      end
      3.times do puts end
       
    end

    if @attempts == MAX_ATTEMPTS 
      puts "YOU LOSE!"
      puts "The word was #{@answer}"
    end
  end
  
  def save
    Dir.mkdir("saves") unless Dir.exists?("saves")
    filename = "#{formatTimeNow}.json"
    f = File.new("saves/#{filename}", "w")
    f.puts serialize
    puts "Created save file: #{filename} in saves/\n\n"
    f.close
  end

  def loadSave(filename)
    f = File.read("saves/#{filename}")
    unserialize(f)
  end


  def formatTimeNow
    opt =""
    arr = Time.now.to_s.split(" ")
    opt="#{arr[0]}--#{arr[1].split(":").join("-")}"
    opt
  end

  def evaluate(chr)
    if @answer.downcase.include?(chr)
      @answer.downcase.split("").each_with_index do |c, index|
        if c == chr
          @holder[index] = chr
        end
      end
    else
      puts"\nOops!"
      @wrong.push(chr) unless @wrong.include?(chr)
    end
  end

  def display 
    @holder.split("").each do|char|
      print "#{char} "
    end
    2.times do puts end
  end
end

puts "H A N G M A N"

newGame = Game.new


if Dir.exists?("saves")
  puts "Load from save?"
  savefiles = Dir.entries("saves").select {|f| !File.directory? f}
  puts "#{savefiles.length} #{savefiles.length ==1? "file": "files"} found."
  savefiles.each_with_index do |filename, index|
    puts "[#{index}] #{filename}"
  end

  puts "Pick a save to load from, or enter (-1) to start a new game:"
  while true do
    input = gets.chomp
    if input.to_i < 0
      puts "creating new game..."
      break
    
    elsif input.match?(/^[0-9]+$/)
      newGame.loadSave(savefiles[input.to_i])
      puts "valid "
      break
    else
      puts "invalid"
    end
  end

 
end


newGame.start





