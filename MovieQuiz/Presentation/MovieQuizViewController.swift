import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlet
    @IBOutlet private var imageView    : UIImageView!
    @IBOutlet private var textLabel    : UILabel!
    @IBOutlet private var counterLabel : UILabel!
    @IBOutlet weak var noButton        : UIButton!
    @IBOutlet weak var yesButton       : UIButton!
    
    // MARK: - Private Properties
    private var questionsCount       = 10
    private var currentQuestionIndex = 0
    private var correctAnswers       = 0
    
    private var currentQuestion : QuizQuestion?
    private var questionFactory : QuestionFactory?
    private var alertPresenter  : AlertPresenter?
    private var statisticSevice : StatisticService?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactoryImpl(delegate      : self)
        alertPresenter  = AlertPresenterImpl(viewController : self)
        statisticSevice = StatisticServiceImpl()
        
        imageView.layer.cornerRadius = 20
        
        questionFactory?.requestNextQuestion()    }
    
    // MARK: - IB Acction
    @IBAction func yesButtonClicked(_ sender : Any) {
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    @IBAction func noButtonClicked(_ sender: Any) {
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion?.correctAnswer)
    }
    
    
    
    // MARK: - Private Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(), // 2
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsCount)") // 4
        return questionStep
    }//
    
    private func show(quiz step: QuizStepViewModel) {
        //the button is enabled
        noButton.isEnabled  = true
        yesButton.isEnabled = true
        imageView.image     = step.image
        textLabel.text      = step.question
        counterLabel.text   = step.questionNumber
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
    }//
    
    private func showQuestion(){
        
        questionFactory?.requestNextQuestion()
        imageView.layer.borderColor = UIColor.ypBlack.cgColor
        
    }//
    
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
    }//
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsCount - 1 {
            showFinalResults()
        }else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }//
    
    private func showFinalResults() {
        statisticSevice?.store(correct: correctAnswers, total: questionsCount )
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: makeResultMessage(),
            buttonText: "Сыграть еще раз",
            buttonAction: {[weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers       = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
    
        alertPresenter?.show(alertModel: alertModel)
    }//
    
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
    }//
    
    
    
    
}//ViewController


extension MovieQuizViewController: QuestionFactoryDelegate {
    
    func didReceiveQuestion(_ question: QuizQuestion) {
        self.currentQuestion = question
        let viewModel        = self.convert(model : question)
        self.show(quiz: viewModel)
    }
}
