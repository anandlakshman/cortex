staging:
  sessions:
    default:
      database: <%= ENV['MONGODB_DATABASE']%>
      hosts: <%= "[\"#{ENV['MONGODB_ADDRESS']}:27017\"]" %>
