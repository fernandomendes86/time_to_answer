class Site::AnswerController < SiteController

  def question
    #@answer = Answer.find(params[:answer_id])
    #Redis
    redis_answer = Redis.new.get(params[:answer_id]).split("@@")
    @question_id = redis_answer.first
    @correct = redis_answer.last == "true" ? true : false
    #-

    UserStatistic.set_statistic(@correct, current_user)
    
  end

end
