//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController {
    static let productID = "us.eduserve.InspoQuotes.PremiumQuotes"
    
    var hasPurchasedPremiumQuotes:Bool {
        return UserDefaults.standard.bool(forKey: QuoteTableViewController.productID)
    }
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showPremiumQuotes()
        
        SKPaymentQueue.default().add(self)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return quotesToShow.count + (hasPurchasedPremiumQuotes ? 0 : 1)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.row == quotesToShow.count {
            cell.textLabel?.text = "Get More Quotes!"
            cell.textLabel?.textColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            cell.textLabel?.textColor = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    // MARK: - Table view delegate source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - In-App Purchases
    
    //MARK: - IBActions
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

//MARK: - SKPaymentTransactionObserver methods

extension QuoteTableViewController: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                print("Transaction in progress")
            case .purchased:
                print("Transaction successful")
                unlockContent(transaction: transaction)
            case .failed:
                print("Transaction failed")
                if let error = transaction.error {
                    print("Transaction error: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                print("Transaction restore request")
                unlockContent(transaction: transaction)
            case .deferred:
                print("Transaction deferred")
            @unknown default:
                print("Transaction unknown")
            }
        }
    }
    
    func unlockContent(transaction:SKPaymentTransaction) {
        print("Unlocking premium content...")
        UserDefaults.standard.set(true, forKey: QuoteTableViewController.productID)
        navigationItem.setRightBarButton(nil, animated: true)
        showPremiumQuotes()
        
        // Call after unlocking content
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    func showPremiumQuotes() {
        if hasPurchasedPremiumQuotes {
            print("Premium content unlocked")
            quotesToShow.append(contentsOf: premiumQuotes)
        }
        else {
            print("Premium content NOT unlocked")
        }
        tableView.reloadData()
    }
    
    func buyPremiumQuotes() {
        if SKPaymentQueue.canMakePayments() {
            print("User initiated purchase...")
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = QuoteTableViewController.productID
            
            SKPaymentQueue.default().add(paymentRequest)
        }
        else {
            print("User can't make payments.")
        }
    }
}
