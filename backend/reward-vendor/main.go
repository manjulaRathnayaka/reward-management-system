package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"go.uber.org/zap"
)

type Reward struct {
	RewardId  string `json:"rewardId"`
	UserId    string `json:"userId"`
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Email     string `json:"email"`
}

type RewardConfirmation struct {
	RewardConfirmationNumber string `json:"rewardConfirmationNumber"`
	UserId                   string `json:"userId"`
	RewardId                 string `json:"rewardId"`
}

var logger *zap.Logger
var rewards []Reward

var rewardConfirmationWebhookUrl = os.Getenv("REWARD_CONFIRMATION_WEBHOOK_URL")

func RespondWithRewardConfirmation(rewardId string, userId string) {
	logger.Info("responding with reward confirmation")

	// Generate the 16-digit number and encapsulate in an anonymous struct
	rewardConfirmation := RewardConfirmation{
		RewardConfirmationNumber: Generate16DigitNumber(),
		UserId:                   userId,
		RewardId:                 rewardId,
	}

	// Convert the anonymous struct to JSON
	data, err := json.Marshal(rewardConfirmation)
	if err != nil {
		logger.Error("Failed to marshal data", zap.Error(err))
	}

	resp, err := http.Post(rewardConfirmationWebhookUrl, "application/json", bytes.NewBuffer(data))
	if err != nil {
		logger.Error("Failed to send POST request", zap.Error(err))
	}
	defer resp.Body.Close()

	// Optionally, handle non-200 status codes
	if resp.StatusCode != http.StatusAccepted {
		logger.Warn("Webhook responded with non-200 status code", zap.Int("statusCode", resp.StatusCode))
	} else {
		logger.Info("Successfully sent reward confirmation", zap.Any("rewardConfirmation", rewardConfirmation))
	}

}

func Generate16DigitNumber() string {
	src := rand.NewSource(time.Now().UnixNano())
	r := rand.New(src)
	// To ensure it's always 16 digits, generate a number between 1000_0000_0000_0000 and 9999_9999_9999_9999
	number := r.Int63n(9000_0000_0000_0000) + 1000_0000_0000_0000

	return fmt.Sprintf("%016d", number)
}

func HandleCreateReward(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var reward Reward
	_ = json.NewDecoder(r.Body).Decode(&reward)

	logger.Info("creating a reward", zap.Any("reward", reward))

	rewards = append(rewards, reward)
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(reward)

	logger.Info("responding with reward confirmation", zap.Any("reward", reward))
	RespondWithRewardConfirmation(reward.RewardId, reward.UserId)
}

func main() {
	defer logger.Sync() // Ensure all buffered logs are written

	logger.Info("Starting the reward vendor...")

	r := mux.NewRouter()

	// Sample Data
	rewards = append(rewards, Reward{RewardId: "RWD0000", UserId: "U0000", FirstName: "John", LastName: "Doe", Email: "john@example.com"})
	r.HandleFunc("/rewards", HandleCreateReward).Methods("POST")
	http.ListenAndServe(":8080", r)
}

func init() {
	var err error
	logger, err = zap.NewProduction()
	if err != nil {
		panic(err)
	}
}
