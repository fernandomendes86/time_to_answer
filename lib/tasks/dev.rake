namespace :dev do

  DEFAULT_PASSWORD = 123456
  
  DEFAULT_FILES_PATH = File.join(Rails.root, 'lib', 'tmp')


  desc "Cria o ambiente de desenvolvimento"
  task setup: :environment do
    if Rails.env.development?
  		show_spinner("Apagando BD...") do
  			%x(rails db:drop)
  		end

  		show_spinner("Criando BD...") do
  			%x(rails db:create)
  		end

  		show_spinner("Migrando BD...") do
  			%x(rails db:migrate)
      end
    end
      
      show_spinner("Cadastrando Admin Padrão...") do
  			%x(rails dev:add_default_admin)
      end

      show_spinner("Cadastrando Admins Extras...") do
  			%x(rails dev:add_extras_admins)
      end
      
      show_spinner("Cadastrando User Padrão...") do
  			%x(rails dev:add_default_user)
      end

      show_spinner("Cadastrando Assuntos padrões...") do
  			%x(rails dev:add_subjects)
      end

      show_spinner("Cadastrando Perguntas e Respostas...") do
  			%x(rails dev:add_answers_and_questions)
      end
      
  	#else
  	  #puts 'Você não está no ambiente de desenvolvimento!'
    #end  
  end

  desc "Adiciona o administrador padrão"
  task add_default_admin: :environment do
    Admin.create!(
      email: 'admin@admin.com',
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adiciona o administradores extras"
  task add_extras_admins: :environment do
    10.times do |i|
      Admin.create!(
        email: Faker::Internet.email,
        password: DEFAULT_PASSWORD,
        password_confirmation: DEFAULT_PASSWORD
      )
    end
  end

  desc "Adiciona o usuário padrao"
  task add_default_user: :environment do
    User.create!(
      email: "user@user.com",
      password: DEFAULT_PASSWORD,
      password_confirmation: DEFAULT_PASSWORD
    )
  end

  desc "Adicionar assuntos padrão"
  task add_subjects: :environment do
    file_name = 'subjects.txt'
    file_path = File.join(DEFAULT_FILES_PATH, file_name)

    File.open(file_path, 'r').each do |line|
      Subject.create!(description: line.strip)
    end
  end

  
  desc "Adiciona perguntas e respostas"
  task add_answers_and_questions: :environment do
    Subject.all.each do |subject|
      rand(5..10).times do
        params = create_question_params(subject)
        answers_array = params[:question][:answers_attributes]
        
        add_answers(answers_array)
        elect_true_answer(answers_array)

        Question.create!(params[:question])
      end
    end
  end

  desc "Reseta a contagem das questões por assunto"
  task reset_subject_counter: :environment do
    show_spinner("Resetando a contagem das questões por assuntos...") do
      Subject.find_each do |subject|
        Subject.reset_counters(subject.id, :questions)
      end
    end 
  end

  private

  def create_question_params(subject = Subject.all.sample)
    { question: {
          description: "#{Faker::Lorem.paragraph} #{Faker::Lorem.question}",
          subject: subject,
          answers_attributes: []
      }
    }
  end

  def create_answer_params(correct = false)
    { description: Faker::Lorem.sentence, correct: correct}
  end

  def add_answers(answers_array = {})
    rand(2..5).times do |j|
      answers_array.push(create_answer_params)
    end
  end

  def elect_true_answer(answers_array = {})
    selected_index = rand(answers_array.size)
    answers_array[selected_index] = create_answer_params(true)
  end

  def show_spinner(msg_inicio, msg_fim = "Concluído!")
    spinner = TTY::Spinner.new("[:spinner] #{msg_inicio}")
    spinner.auto_spin
    yield
    spinner.success("(#{msg_fim})") 
  end

end
