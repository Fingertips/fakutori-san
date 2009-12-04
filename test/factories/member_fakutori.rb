module FakutoriSan
  class MemberFakutori < Fakutori
    def valid_attrs
      { 'name' => 'Eloy', 'email' => 'eloy@example.com', 'password' => 'secret' }
    end
    
    def minimal_attrs
      { 'name' => 'Eloy' }
    end
    
    def invalid_attrs
      {}
    end
    
    def with_arg_attrs(arg)
      { 'arg' => arg }
    end
    
    def with_name_scene(member, options)
      member.update_attribute :name, "#{options[:name]}#{options[:index]}"
    end
    
    def associate_to_article(member, article, options)
    end
    
    def associate_to_namespaced_article(member, article, options)
    end
  end
end