# ActionMessageTexter

以 Rails ActionMailer 為參考打造的簡訊寄送模組，提供與 ActionMailer 一致的開發體驗

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

## Usage


請先執行`generator`

```bash
rails g action_message_texter:texter ModuleName action_name action_name ....
```
這將會產生以下文件

```
root
├─ app
│  └─ texters
│     ├─ application_texter.rb
│     └─ module_name_texter.rb
│
└─ config
   └─ locales
      └─ module_name.yml
```    

使用上大致上跟Mailer差不多

```ruby
# app/texter/my_texter.rb
class MyTexter
  def my_ubereats(phone)
    @order = "林東芳的半筋半肉牛肉麵"
    @notes = "不要牛肉不要麵"
    text(to: phone)
  end
end
```
與Mailer不同的是 簡訊內容不從View Render出來，請使用I18n，或是直接給 `content`

```yaml
# config/locales/texter/my_texter.yaml
zh-TW:
  my_texter:
    my_action: 今晚我想來點%{order}，%{note}
```


```ruby
# app/texter/my_texter.rb
def my_ubereats(phone)  
  ...
  # 也可以直接給文字，不走I18n
  text(to: phone, content: "今晚我想來點#{order}，#{note}")
end
```

跟 ActionMailer 一樣，提供 `deliver_now` 跟 `deliver_later` 兩種寄送方式，`deliver_now` 會直接寄出，`deliver_later`會調用Job做寄出。

```ruby
# 直接寄出，後續的動作需等待這個動作完成
MyTexter.my_ubereats("0987654321").deliver_now
# 調用Job，後續的動作繼續執行
MyTexter.my_ubereats("0987654321").deliver_latter

```

**於是 `0987654321` 就會收到這樣的簡訊**
> 今晚我想來點林東芳的半筋半肉牛肉麵，不要牛肉不要麵



## Configuration

### 設定簡訊傳送方式： 三竹簡訊 API

設定方式基本跟 `ActionMailer` 一模一樣

預設內建三竹簡訊，首先請設定`網域`，`帳號`，`密碼`，如果有需要`Callback`的話，請準備一下`Callback Url`

> 有計劃提供一個介面讓大家可以自己包自己的簡訊Api模組
> 到時候只需使用 `add_delivery_method`  就可以加入自己的 Api 模組


*  Require   
   麻煩請先到`config/application.rb` 新增 `require action_message_texter/engine`

*  設定三竹API
    
    ```ruby
    # config/application.rb
    config.action_message_texter.mitake_settings= { 
      url: "三竹發給你的網域名稱 ex: https://smsapi.mitake.com.tw", 
      username: "三竹的使用者名稱", 
      password: "三竹的密碼", 
      callback_url: "https://foo.bar.com/api/v1/callback" # 這行非必填
    }  
    ```

*  設定預設寄送方式  
   目前只有 `mitake` 一種寄送方式，因此預設就是這個，但若有需要的話
   
   在`app/application.rb`裡，可以預設所有簡訊要使用哪一個寄送方式
   ``` ruby
    # app/application.rb

    #預設值為 :mitake
    config.action_message_texter.delivery_method = :mitake
   ```
   基本上的設定方式都與ActionMailer相同，如果有不知道如何設定的，可以依照設定Mailer的經驗試試看喔


## Message Object

`Message` 物件相當於 `ActionMailer` 中的 `Message` 物件，是簡訊的本體，`Message` 物件包含了這些東西
 - uuid: 簡訊的ID
 - to: 收件者
 - content: 簡訊內容
 - response: 簡訊 Api 的回覆 (此部分可以參考[三竹簡訊API文件](https://sms.mitake.com.tw/common/header/download.jsp#))


## Callbacks

可以在Tester中加入 `before_action` 與 `after_action`，在這兩個方法中可以取得 `message` 物件。
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
    
    # 如傳送後儲存傳送結果
    message_history = MessageHistory.find_by(uuid: message.uuid)
    message_history.update(response_message: message.response.response_message)
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

    # 如測試站時加入測試站專屬訊息
    message.content = "[test]#{message.content}" unless Rails.env.production
  end
end


class MyTexter
  self.register_inspection(TexterObserver)
  
  # 您也可以註冊多組攔截器
  self.register_inspection(OtherObserver)
end
```

## Test

小弟初次寫Gem 還不會寫測試 還請各位神人協助交流 感謝


## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
