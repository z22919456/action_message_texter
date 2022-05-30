# ActionMessageTexter

仿造Rails ActionMailer 打造的簡訊寄送模組，提供與Mailer一致的開發體驗

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'action_message_texter'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install action_message_texter
```

## Configuration

1. 載入設定  
   先到`config/application.rb` 新增 `require action_message_texter/engine`

2. 簡訊寄送方式設定  

    由於簡訊沒有類似SMTP的標準寄送方式，全依照簡訊提供商的API，目前我有包一個基於**三竹簡訊**的API，未來有計畫開放大家自行建立自己的寄送方式
    
    ```ruby
    # config/application.rb
    config.action_message_texter.mitake_settings= :mitake, MitakeApi::SMSProvider, url: "三竹發給你的網域名稱", username: "三竹的使用者名稱", password: "三竹的密碼"
    ```

3. 設定預設寄送方式  
   在`app/application.rb`裡，可以預設所有簡訊要使用哪一個寄送方式
   ``` ruby
    # app/application.rb

    #預設值為 :mitake
    config.action_message_texter.delivery_method = :mitake
   ```
   若要依照不同環境使用不同的簡訊寄送方式 請在不同環境的設定檔(如`config/environments/development.rb`)內覆蓋這個設定，也可以在Texter中使用`delivery_method = :method`直接指定

### 完整設定如下
```ruby
# config/applications.rb

# 引用ActionMessageTexter
require 'action_message_texter/engine'
....

class Application < Rails::Application
  ...
  # 加入三竹科技登入方式
  config.action_message_texter.mitake_settings(:url: ENV['URL'], username: ENV['USERNAME'], password: ENV['password'])
  # 設定預設的寄送方式
  config.action_message_texter.delivery_method = :mitake
  ...
end
```

## Generator 

```bash
rails g action_message_texter:texter ModuleName action_name action_name ....
```
這會產生3個檔案，分別是 `app/texter/application_texter.rb` (若不存在)、`app/texter/{{name}}_texter.rb`、`config/locales/texter/{{name}}_texter.yaml`
若有給定`function_name` 會自動生成對應的 function 以及字典檔


```ruby
# app/texter/my_texter.rb
class MyTexter
  def action_name
    sms(to: "+8860987654321")
  end
end
```
```yaml
# config/locales/texter/my_texter.yaml
zh-TW:
  my_texter:
    action_name: 
    action_name2:
```


## Texter

與Mailer雷同，但因為簡訊是比較單純的文字，因此render view了，簡訊生成的部分將使用`I18n`，同時會自動帶入參數

#### Example
假設要送出簡訊，並帶入訂單
```ruby
class MyTexter
  def uber_eat_order(phone_number, order)
    # 記得設成全域變數 我會幫你自動插到I18n內，就像平常使用view 時會插入 `<%=@order>` 一樣
    @order = order
    sms(to: phone_number)
  end
end
```

```yaml
zh-TW:
  my_texter: 
    uber_eat_order: "今晚，我想來%{order}"
# 記得插值不要加 `@` 喔
```

若不同的`Texter`想使用不同的method 可以直接加入 `delivery_method = :method`

```ruby
class MyTexter
  delivery_method = :method
  ....
```

## Send Message

跟 Mailer 一樣，提供 `deliver_now` 跟 `deliver_later` 兩種寄送方式，`deliver_now` 會直接寄出，`deliver_later`會調用Job做寄出。

```ruby
# 直接寄出，後續的動作需等待這個動作完成
MyTexter.uber_eat_order("0987654321", "林東芳牛肉麵").deliver_now
# 調用Job，後續的動作繼續執行
MyTexter.uber_eat_order("0987654321", "林東芳牛肉麵").deliver_latter

```

## Callbacks

可以在Tester中加入 `before_action` 與 `after_action`，在這兩個funciton中可以取得`message`物件。
```ruby
class MyTexter
  before_action :do_before
  after_action :do_after

  def do_before
    ...do_something
  end

  def do_after
    ...do_something
  end
  ....
```


## Observer

若需要再寄送後，查看寄送是否完成？儲存寄送方式結果...等
可以註冊一個 `Observer` 或多個 `Observer`

```ruby
class TexterObserver
  def self.delivered_message(message)
    # 請實作此方法
  end
end


class MyTexter
  self.register_observer(TexterObserver)
  
  # 您也可以註冊多組Observer
  self.register_observer(OtherObserver)
end
```

## Inspection

如了`Observer` 您也可以註冊攔截器 `Inspection`

```ruby
class TexterInspection
  def self.delivering_message(message)
    # 請實作此方法
  end
end


class MyTexter
  self.register_inspection(TexterObserver)
  
  # 您也可以註冊多組Observer
  self.register_inspection(OtherObserver)
end
```
## Test

尚未規劃Test的部分


## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
