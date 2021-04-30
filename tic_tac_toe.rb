require 'json'

class Game
    def self.load
        file = File.open("JSON/tic_tac_toe.json", "r")
        content = file.readlines
        markers = JSON.parse(content[0])
        players = JSON.parse(content[1])
        file.close

        player1 = Player.new(players['player1']['name'], players['player1']['marker'])
        player2 = Player.new(players['player2']['name'], players['player2']['marker'])
        player = players['player'] == players['player1']['player'] ? player1 : player2 

        game = Game.new(player1, player2, markers, player)

        has_ended = false

        until has_ended
            has_ended = game.play
        end
    end

    def initialize(player1, player2, markers = nil, player = nil)
        @player1 = player1
        @player2 = player2

        @player = player == nil ? player2 : player 

        if !markers
            file = File.open("JSON/tic_tac_toe.json", "w")
            markers = {"1" => "1", "2" => "2", "3" => "3", "4" => "4", "5" => "5", "6" => "6", "7" => "7", "8" => "8", "9" => "9"}
            file.puts JSON.dump (markers)
            file.close
        end
    end

    def play
        @player = @player == @player1 ? @player2 : @player1

        file = File.open("JSON/tic_tac_toe.json", "r")
        markers = file.readlines
        markers = JSON.parse(markers[0])
        file.close

        print_board(markers)

        puts "#{@player.name}: Choose a number"
        number = gets.chomp

        if markers[number] == number
            markers[number] = @player.marker
        else
            until markers[number] == number
                puts "#{@player.name}: Please choose a number that was not selected previously"
                number = gets.chomp
            end

            markers[number] = @player.marker
        end

        if (markers.values & ['1', '2', '3', '4', '5', '6', '7', '8', '9']).empty?
            Game.loose

            file = File.open("JSON/tic_tac_toe.json", "w")
            file.puts JSON.dump (nil)
            file.close

            return true
        end

        file = File.open("JSON/tic_tac_toe.json", "w")
        file.puts JSON.dump (markers)
        file.puts JSON.dump ({'player1' => {'player' => @player1, 'name' => @player1.name, 'marker' => @player1.marker}, 'player2' => {'player' => @player2, 'name' => @player2.name, 'marker' => @player2.marker}, 'player' => @player})
        file.close

        if Game.win?(markers)
            Game.win(@player)

            file = File.open("JSON/tic_tac_toe.json", "w")
            file.puts JSON.dump (nil)
            file.close

            return true
        else
            return false
        end
    end

    private

    def self.win?(markers)
        if markers['1'] == markers['2'] and markers['2'] == markers['3']
            return true
        elsif markers['4'] == markers['5'] and markers['5'] == markers['6']
            return true
        elsif markers['7'] == markers['8'] and markers['8'] == markers['9']
            return true 
        elsif markers['1'] == markers['4'] and markers['4'] == markers['7']
            return true
        elsif markers['2'] == markers['5'] and markers['5'] == markers['8']
            return true
        elsif markers['3'] == markers['6'] and markers['6'] == markers['9']
            return true
        elsif markers['1'] == markers['5'] and markers['5'] == markers['9']
            return true
        elsif markers['3'] == markers['5'] and markers['5'] == markers['7']
            return true
        else
            return false
        end
    end

    def self.win(player)
        puts "#{player.name} won!!"
    end

    def self.loose
        puts "No one won :("
    end

    def print_board(markers)
        puts ''
        puts " #{markers['1']} | #{markers['2']} | #{markers['3']} "
        puts "---+---+---"
        puts " #{markers['4']} | #{markers['5']} | #{markers['6']} "
        puts "---+---+---"
        puts " #{markers['7']} | #{markers['8']} | #{markers['9']} "
        puts ''
    end
end

class Player
    attr_accessor :marker, :name

    def initialize(name = nil, marker = nil)
        @marker = marker
        @name = name
    end

    def ask_name
        print "Player Name: "
        @name = gets.chomp
    end

    def ask_marker
        print "Player Marker: "
        @marker = gets.chomp
    end

    def valid?(compare = nil)
        if @marker == nil || @marker.length > 1 || Integer(marker, exception: false)
            return false
        else  
            if compare != nil
                if compare.marker == @marker
                    return false
                else
                    return true 
                end
            else
                return true
            end
        end
    end
end

file = File.open("JSON/tic_tac_toe.json", "r")
content = file.readlines
content = JSON.parse(content[0])
file.close

if content != nil
    puts "Do you want to load the previous game?"
    load_game = gets.chomp
end

unless load_game == 'yes' || load_game == 'y' || load_game == 'true'
    player1 = Player.new()
    player1.ask_name

    until player1.valid?
        puts "Please choose a marker that is one character long and is not a number"
        player1.ask_marker
    end

    player2 = Player.new()
    player2.ask_name

    until player2.valid?(compare = player1)
        puts "Please choose a marker that is one character long and is not a number"
        player2.ask_marker
    end

    has_ended = nil

    game = Game.new(player1, player2)

    until has_ended
        has_ended = game.play
    end
else
    Game.load 
end