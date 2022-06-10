class <%="#{class_name}"%>Texter < ActionMessageTexter::Base
  <%actions.each do |action| %>
    def <%=action%>
      text(to: "+886987654321")
    end
  <%end%>
end