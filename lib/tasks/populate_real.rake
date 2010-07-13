
namespace :db do 
  namespace :populate do
    desc 'Erase database'
    task :erase => :environment  do
      erase
    end

    desc 'Erase and fill database'
    task :real => :environment  do
      require 'populator'

      erase
      
      env = Environment.new(:is_default => true)
      env.design_data = {:template => 'default', :theme => 'default', :icon_theme => 'default'}
      env.save!

      Role.create!(:name => 'Moderator', :permissions => ['survey_viewing', 'survey_editing', 'survey_erasing'])  
      Role.create!(:name => 'Editor', :permissions => ['survey_viewing', 'survey_editing'])  
      Role.create!(:name => 'Collaborator', :permissions => ['survey_viewing'])  

      User.populate 1 do |user|
        user.login = 'admin'
        user.administrator = true
        user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
        user.email = 'admin@localhost'
      end 

      survey = nil
      Survey.populate 1 do |survey|
        survey.title = "Você está Seguro(a) Online?"
        survey.design_data = {:template => 'default', :theme => 'default', :icon_theme => 'default'}
        survey.subtitle = "Olá! Bem vindo(a) a pesquisa Você está Seguro(a) Online?"
        survey.introduction = "As respostas que você fornecer são anônimas, o que significa que o seu nome não será identificado."
        survey.is_private = false
        survey.number_of_pages = 5 #TODO
        survey.user_id = User.first.id #CREATOR
      end
      
      questions = [
                   ["Section", "Sobre você", 1],
                   ["Question", "Idade", 1, "single_selection", ["5 a 9 anos", "10 a 13 anos", "14 a 17 anos"]],
                   ["Question", "Gênero", 1, "radiobutton", ["Feminino", "Masculino"]],
                   ["Question", "Em qual Estado você mora?", 1, "single_selection", 
                    ["ACRE", "ALAGOAS", "AMAPÁ", "AMAZONAS", "BAHIA", "CEARÁ", "DISTRITO FEDERAL", "ESPÍRITO SANTO", "GOIÁS", "MARANHÃO", "MATO GROSSO", "MATO GROSSO DO SUL", "MINAS GERAIS", "PARÁ", "PARAÍBA", "PARANÁ", "PERNAMBUCO", "PIAUÍ", "RIO DE JANEIRO", "RIO GRANDE DO NORTE", "RIO GRANDE DO SUL", "RONDÔNIA", "RORAIMA", "SANTA CATARINA", "SÃO PAULO", "SERGIPE", "TOCANTINS"]],
                   ["Question", "Em que cidade você mora?", 1, "pure_text"],
                   ["Question", "Em que bairro você mora?", 1, "pure_text"],
                   ["Question", "Sua escola é:", 1, "radiobutton", ["Estadual", "Federal", "Municipal", "Particular", "Não estou estudando"]],
                   ["Question", "Em qual série você estuda?", 1, "radiobutton", ["1° ao 5° ano - Ensino Fundamental I", "6° ano ao 9° ano - Ensino Fundamental II", "1° ano ao 3° ano - Ensino Médio", "Não estou estudando"]],
                   ["Question", "Quais destas TIC você tem em casa?", 1, "checkbox", ["TV", "Computador", "Notebook", "Videogame", "TV a Cabo", "Internet Banda Larga", "Celular", "Nenhum anterior", "Outros:"], [1, 8]],
                   ["Question", "Qual destas afirmativas melhor reflete sua visão de seu bairro?", 1, "radiobutton", ["Meu bairro é um lugar seguro e divertido para passear", "Meu bairro é normal", "Meu bairro NÃO é seguro e não gosto de passear por ele", "Não tenho certeza do que responder", "Não sei"]],
                   ["Question", "O que melhor descreve o quanto se sente seguro(a)?", 1, "radiobutton",   ["Me sinto seguro(a)", "Me sinto seguro(a) de vez em quando", "Não me sinto seguro(a)", "Não tenho certeza do que responder"]],
                   ["Question", "O que melhor descreve sua experiência com a violência?", 1, "radiobutton", ["Eu nunca vi violência no meu bairro ", "Eu já vi violência no bairro acontecendo com outras pessoas", "Já aconteceu violência comigo", "Não tenho certeza do que responder", "Não sei"]],
                   ["Section", "TIC na sua vida", 2],
                   ["Question", "Que atividades você faz?", 2, "pure_text"],
                   ["Question", "Você assiste a TV?", 2, "radiobutton",   ["Sim", "Não", "Não sei responder"]],
                   ["Question", "Você joga videogame?", 2, "radiobutton",   ["Sim", "Não", "Não sei responder"]],
                   ["Question", "Você acha que os meninos e as meninas gostam do mesmo tipo de videogames?", 2, "radiobutton",   ["Sim", "Não"]],
                   ["Question", "Você já usou Internet alguma vez na vida?", 2, "radiobutton",   ["Sim", "Não"]],
                   ["Question", "Que atividades você faz no celular?", 2, "pure_text"],
                   ["Section", "Perigos e Proteção Online", 3],
                   ["Question", "Algum comentário final que deseja compartilhar?", 3, "pure_text"]]

      iv_map = []
      
      pos = 1
      questions.each do |q|
        params = { :info => q[1], :position => pos, :survey_id => survey.id, :page_id => q[2], :type => q[0].downcase }
        if q[0].downcase == "question"
          params[:html_type] = Item.html_types.invert[q[3]]
          item = Question.create(params)
          iv_map.push([item.id.to_s])
          iv_opt = []
          
          p = 1
          if q[3] != "pure_text"
            aux = q[5].nil? ? 0 : 1

            iv_map[-1].push(aux)
            iv_map[-1].push(iv_opt)
            q[4].each do |iv|
              it = ItemValue.create(:item_id => item.id, :position => p, :info => iv)
              p += 1
              iv_opt.push(it.id.to_s)
            end
          else
            iv_map[-1].push(2)
          end
          if q[5].nil?
            item.max_answers = item.min_answers = 0
          else
            item.min_answers = q[5][0]
            item.max_answers = q[5][1]
          end
          item.save
        else
          item = Section.create(params)
        end
        pos += 1
      end

      answers = [[0, 0, 4, "Salvador", "Graça", 3, 0, [0, 1, 2, 3, 4, 5, 6], 0, 0, 0, "Estudo, faço balé, canto", 0, 1, 1, 0, "Mando mensagem, olho internet, falo com as amigas", "Não, obrigada"],
                 [1, 1, 18, "Rio de Janeiro", "Tijuca", 2, 1, 0, 2, 2, 2, "Estudo, brinco, vendo bala", 0, 0, 1, 0, "Não tenho", "Sinto muito medo de vender bala na rua"],
                 [0, 0, 24, "São Paulo", "Moema", 3, 0, [0, 1, 4, 5, 6], 1, 1, 1, "Danço jazz", 0, 1, 1, 0, "Mando SMS, navego na internet", "Não"],
                 [1, 1, 24, "Campinas", "Centro", 0, 1, [0, 1, 2, 3, 5, 6], 1, 0, 1, "Estudo, toco violão", 1, 0, 0, 0, "Jogo, mando mensagem, navego na internet", "Não"]]

      answers.each { |a|
        quest = Questionnaire.new
        q = build_quest(iv_map, a)
        quest.prepare_to_save(q, survey.id.to_i)
      }
      
      User.populate 6 do |user|
        user.administrator = false
        user.crypted_password = '44d5d03bfe8570fbfaa630a3520b33724c397ea9' #encriptation for 123456 password
      end
      
      @users = User.find(:all, :conditions => {:administrator => false})
      Survey.find(:all).each do |survey|
        moderator = @users.first
        moderator.add_role(Role.find_by_name('Moderator'), survey)
        moderator.login = "rodrigo"
        moderator.name = "Rodrigo"
        moderator.email = moderator.login + '@localhost.com'
        moderator.save!; moderator.reload
        @users.delete_at(0)

        editor = @users.first
        editor.add_role(Role.find_by_name('Editor'), survey)
        editor.login = "aline"
        editor.name = "Aline"
        editor.email = editor.login + '@localhost.com'
        editor.save!; editor.reload
        @users.delete_at(0)

        collaborator = @users.first
        collaborator.add_role(Role.find_by_name('Collaborator'), survey)
        collaborator.login = "caio"
        collaborator.name = "Caio"
        collaborator.email = collaborator.login + '@localhost.com'       
        collaborator.save!; collaborator.reload
        @users.delete_at(0)
        
        collaborator = @users.first
        collaborator.login = "caiosba"
        collaborator.name = "Caio SBA"
        collaborator.email = collaborator.login + '@localhost.com'       
        collaborator.save!; collaborator.reload
        @users.delete_at(0)

        
        collaborator = @users.first
        collaborator.login = "daniel"
        collaborator.name = "Daniel"
        collaborator.email = collaborator.login + '@localhost.com'       
        collaborator.save!; collaborator.reload
        @users.delete_at(0)

        collaborator = @users.first
        collaborator.add_role(Role.find_by_name('Collaborator'), survey)
        collaborator.login = "leo"
        collaborator.name = "Leandro"
        collaborator.email = collaborator.login + '@localhost.com'       
        collaborator.save!; collaborator.reload
        @users.delete_at(0)
      end
      
      
      
      survey.is_active = true
      survey.save
    end


    def erase
      [Environment, Role, Survey, User, Permission, Item, ObjectItemValue, Questionnaire].each(&:delete_all)
    end

  end
end

private
def format_iv(iv_map, answers, iquestion)
  id, type, values = *iv_map[iquestion]
  alternative = answers[iquestion]
  case type
  when 0
    return [id, values[alternative]]
  when 1
    alts = []
    if alternative.kind_of?Array
      alternative.each { |it| alts.push(it)}
    else
      alts.push(alternative)
    end
    return [id, alts]
  when 2
    return [id, { "info" => alternative }]
  end
end

def build_quest(iv_map, answers)
  quest = {}
  answers.each_with_index { |a, i|
    iv = format_iv(iv_map, answers, i)
    quest[iv[0]] = iv[1]
  }
  return quest
end
