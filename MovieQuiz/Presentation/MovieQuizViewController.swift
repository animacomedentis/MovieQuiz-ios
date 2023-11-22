import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlet
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var questionsCount = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactory?
    private var alertPresenter: AlertPresenter?
    private var statisticSevice: StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader:MoviesLoader(),delegate : self)
        alertPresenter = AlertPresenterImpl(viewController : self)
        statisticSevice = StatisticServiceImpl()
        
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - IB Acction
    @IBAction private func yesButtonClicked(_ sender : Any) {
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)")
    }
    
    private func show(quiz step: QuizStepViewModel) {
        //the button is enabled
        noButton.isEnabled  = true
        yesButton.isEnabled = true
        imageView.image     = step.image
        textLabel.text      = step.question
        counterLabel.text   = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }
    
    private func showQuestion(){
        
        questionFactory?.requestNextQuestion()
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth   = 8
        imageView.layer.borderColor   = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // the button is off
        noButton.isEnabled  = false
        yesButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsCount - 1 {
            showFinalResults()
        }else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showFinalResults() {
        statisticSevice?.store(correct: correctAnswers,
                               total: questionsCount )
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз",
            buttonAction: {[weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
            
        )
        alertPresenter?.show(alertModel: alertModel)
        
    }
    
    private func makeResultMessage() -> String{
        
        guard let statisticSevice = statisticSevice, let bestGame = statisticSevice.bestGame else{
            assertionFailure("error message")
            return ""
        }
        
        let resultMessge =
        """
            Ваш результат:\(correctAnswers)/\(questionsCount)
            Количество сыгранных квизов: \(statisticSevice.gamesCount)
            Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString)
            Средняя точность: \(String(format: "%.2f", statisticSevice.totalAccuracy))%
        """
        return resultMessge
    }
    
    //MARK: Error indicator
    //функция показа индикатора загрузки
    private func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    //функция показа индикатора загрузки
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    //функция показа алерта об ошибке загрузки
    private func showNetworkError(message: String){
        
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Что-то пошло не так(",
            message: "Невозможно загрузить данные",
            buttonText : "Попробовать ещё раз",
            buttonAction: { [weak self]  in
                guard let self = self else{return}
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                
                self.questionFactory?.requestNextQuestion()
            })
        
        alertPresenter?.show(alertModel: alertModel)
    }
    
}//ViewController


extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didLoadDataFromServer(){
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didReceiveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel        = self.convert(model : question)
        self.show(quiz: viewModel)
    }
    
    func didFailToLoadData(with error: Error){
        showNetworkError(message: "Пришла ошибка от сервера")
    }
}//MovieQuizViewController
