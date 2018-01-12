class QuestionsController < ApplicationController
  before_action :load_question, only: [:edit, :update, :destroy]

  before_action :authorize_user, except: [:create]

  # @question у нас будет лежать вопрос с нужным id равным params[:id].
  def edit
  end

  def create
    @question = Question.new(question_params)

    if @question.save
      redirect_to user_path(@question.user), notice: 'Вопрос задан'
    else
      render :edit
    end
  end

  def update
    if @question.update(question_params)
      redirect_to user_path(@question.user), notice: 'Вопрос сохранен'
    else
      render :edit
    end
  end

  def destroy
    # Сохраним пользователя вопроса для редиректа
    user = @question.user

    @question.destroy
  end

  private

  def authorize_user
    reject_user unless @question.user == current_user
  end

  def load_question
    @question = Question.find(params[:id])
  end

  def question_params
    if current_user.present? &&
       params[:question][:user_id].to_i == current_user.id
      params.require(:question).permit(:user_id, :text, :answer)
    else
      params.require(:question).permit(:user_id, :text)
    end
  end
end
