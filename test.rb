# game.rb
require 'gosu'

# ボールクラス
class Ball
  def initialize(window) 
    @window = window
    @x = rand(@window.width)
    @y = 0
    @radius = 15              #大きさ(当たり判定)
    @speed = 5               #落ちる速さ
    @color = Gosu::Color::RED #色指定
  end

  def update
    @y += @speed
  end

  def draw
    @window.draw_rect(@x - @radius, @y - @radius, @radius * 2, @radius * 2, @color)     #四角形を生成し、描写
  end

  def x
    @x
  end

  def y
    @y
  end

  def radius
    @radius
  end
end

# プレイヤー（キャラクター）クラス
class Player
  def initialize(window)
    @window = window
    @x = @window.width / 2
    @y = @window.height - 50
    @radius = 20
    @color = Gosu::Color::BLUE
    @speed = 5
  end

  def update
    if @window.button_down?(Gosu::KB_LEFT)
      @x -= @speed
    end
    if @window.button_down?(Gosu::KB_RIGHT)
      @x += @speed
    end
    # 画面外に出ないようにする
    @x = [[@x, @radius].max, @window.width - @radius].min
  end

  def draw
    @window.draw_rect(@x - @radius, @y - @radius, @radius * 2, @radius * 2, @color)
  end

  def x
    @x
  end

  def y
    @y
  end

  def radius
    @radius
  end
end

# ゲームのメインウィンドウ
class GameWindow < Gosu::Window
  def initialize
    super(640, 480)
    self.caption = "ボール避けゲーム"
    @player = Player.new(self)
    @balls = []
    @last_ball_spawn = Gosu.milliseconds
    @font = Gosu::Font.new(20)
    @score = 0
    @game_over = false
  end

  def update
    return if @game_over

    @player.update
    @balls.each do |ball|
      ball.update
    end

    # 新しいボールを生成
    if Gosu.milliseconds - @last_ball_spawn > 500
      @balls << Ball.new(self)
      @last_ball_spawn = Gosu.milliseconds
    end

    # 画面外に出たボールを削除
    @balls.reject! { |ball| ball.y > self.height + ball.radius }

    # 当たり判定
    @balls.each do |ball|
      distance = Gosu.distance(@player.x, @player.y, ball.x, ball.y)
      if distance < @player.radius + ball.radius
        @game_over = true
      end
    end

    @score += 1 unless @game_over
  end

  def draw
    @player.draw
    @balls.each do |ball|
      ball.draw
    end
    @font.draw_text("スコア: #{@score}", 10, 10, 1)

    if @game_over
      game_over_text = "ゲームオーバー！ スコア: #{@score}"
      text_width = @font.text_width(game_over_text)
      @font.draw_text(game_over_text, (self.width - text_width) / 2, self.height / 2, 1)
      @font.draw_text("Rキーでリスタート", (self.width - @font.text_width("Rキーでリスタート")) / 2, self.height / 2 + 30, 1)
    end
  end

  def button_down(id)
    if @game_over && id == Gosu::KB_R
      initialize
    end
  end
end

# ゲーム開始
GameWindow.new.show