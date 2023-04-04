from __future__ import annotations
from datetime import datetime
import os, sys, math, decimal, enum

# Name of transactions file, which holds all transaction strings.
TRANSACTIONS_FILE_NAME = 'bankingInfo.txt'

# Set of allowed characters for first and last names.
ALLOWED_NAME_CHARACTERS = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ -'

# Indexes for getting specific items from transaction strings.
DATETIME_IDX         = 0
USER_NAME_IDX        = 1
FIRST_NAME_IDX       = 2
LAST_NAME_IDX        = 3
TRANSACTION_TYPE_IDX = 4
CHEQUING_BALANCE_IDX = 5
SAVINGS_BALANCE_IDX  = 6

# Multi-line strings for program GUI.
GUI_ACCOUNT_LOG_IN = """
____________________________________

Log in or create a new account.

| [1] Create a new account         |
| [2] Log in to existing account   |
| [Q] Quit the session             |
____________________________________
"""

GUI_CLIENT_MENU = """
____________________________________

       Bank of Bassoon (BoB)
      
      "Banking made bass-ic"

            Client Menu
____________________________________

Good {}, {}

Your current account balances (CAD):

Chequing: {:10.2f}
Savings:  {:10.2f}
____________________________________

Make a transaction.

| [1]: Sign out                    |
| [2]: Deposit                     |
| [3]: Withdraw                    |
| [4]: Transfer                    |
| [5]: Display transaction history |
| [Q]: Quit the session            |
____________________________________
"""

GUI_ACCOUNT_SELECTOR = """
____________________________________

Select account to {}.

| [C]: Chequing                    |
| [S]: Savings                     |    
____________________________________
"""

GUI_CONFIRM_TRANSACTION = """
____________________________________

Confirm transaction?
{}

| [Y]: Confirm                     |
| [N]: Cancel                      |
____________________________________
"""

GUI_TRANSACTION_HISTORY = """
____________________________________

Transaction history for {} {}.

"""

# Define an exception for invalid dollar amounts.
class InvalidAmountError(Exception):
    pass

# Define an enum to hold status types.
class Status(enum.Enum):
    OK    = 0
    ERROR = 1

# Define a function to print status messages in colour.
def statusMessage(text: str, status: Status):
    match status:
        case Status.OK   : print('\033[92m{}\033[00m'.format(text)) # Green.
        case Status.ERROR: print('\033[91m{}\033[00m'.format(text)) # Red.

# Define a function to get input from client in colour.
def queryMessage(text: str=''):
    text += '\n-> '
    return input('\033[94m{}\033[00m'.format(text)) # Light blue.

# Check if the transactions file exists, abort if none is found.
if not os.path.exists(TRANSACTIONS_FILE_NAME):
    statusMessage('No transactions file found.', Status.ERROR)
    sys.exit()

# Define a client class to store all the client's information.
class Client:
    def __init__(self) -> None:
        # Initialize a client either through a new account or logging into an old one.
        self.transaction_history = []

        # Read all transactions from the transactions file.
        with open(TRANSACTIONS_FILE_NAME, 'r') as f:
            lines = f.readlines() 

        # Keep looping until a client has succesfully been made.
        while len(self.transaction_history) == 0:
            print(GUI_ACCOUNT_LOG_IN)
            command = queryMessage().upper()

            # Make new account.
            if command == '1':
                # Prompt for user name and check if it's valid.
                user_name = queryMessage('Create a user name for your account:').strip()
                if not user_name.isalpha():
                    os.system('cls')
                    statusMessage('User name may contain only alphabetical characters.', Status.ERROR)
                    continue
                elif any(user_name.upper() == line.split('|')[USER_NAME_IDX].upper() for line in lines):
                    statusMessage('User name already taken.', Status.ERROR)
                    continue

                # Prompt for first name and check if it is valid.
                first_name = queryMessage('Enter your first name:')
                if not all(char in ALLOWED_NAME_CHARACTERS for char in first_name):
                    os.system('cls')
                    statusMessage('First name may not contain special characters.', Status.ERROR)
                    continue

                # Prompt for last name and check if it is valid.
                last_name = queryMessage('Enter your last name:')
                if not all(char in ALLOWED_NAME_CHARACTERS for char in last_name):
                    os.system('cls')
                    statusMessage('Last name may not contain special characters.', Status.ERROR)
                    continue
                
                # Create a transaction log entry and append to file.
                transaction = f'\n{datetime.now().strftime("%Y-%m-%d %H:%M:%S")}|{user_name}|{first_name}|{last_name}|ACCOUNT_OPEN|0.00|0.00|0.00'
                with open(TRANSACTIONS_FILE_NAME, 'a') as f:
                    f.write(transaction)
                self.transaction_history.append(transaction.split('|'))

            # Sign in to old account.
            elif command == '2':
                # Prompt for user name.
                user_name = queryMessage('User name:')

                # Loop through transaction file and get client info.
                for line in lines:
                    transaction = line.split('|')
                    if transaction[USER_NAME_IDX].upper() == user_name.upper():
                        self.transaction_history.append(transaction)

                # Continue if no info on client was found.
                if len(self.transaction_history) == 0:
                    os.system('cls')
                    statusMessage(f'No account under {user_name}', Status.ERROR)
                    continue
            
            # Quit the program
            elif command == 'Q':
                # Clear screen and print leave message.
                os.system('cls')
                statusMessage('Thank you for choosing BoB.', Status.OK)
                sys.exit()

            # Invalid command.
            else:
                statusMessage(f'Invalid command: {command}', Status.ERROR)

        # Get latest transaction by indexing transaction history by last entry.
        latest_transaction = self.transaction_history[-1]

        # Store all latest client information.
        self.user_name  = latest_transaction[USER_NAME_IDX]
        self.first_name = latest_transaction[FIRST_NAME_IDX]
        self.last_name  = latest_transaction[LAST_NAME_IDX]

        # Use built-in Decimal type instead of floating-point for better precision and less rounding errors.
        # Source: https://spin.atomicobject.com/2014/08/14/currency-rounding-errors/
        self.chequing_balance = decimal.Decimal(latest_transaction[CHEQUING_BALANCE_IDX])
        self.savings_balance  = decimal.Decimal(latest_transaction[SAVINGS_BALANCE_IDX])
    
    # Ensure that amount literal is a valid currency amount.
    def getValidAmount(self, amount_str: str):
        # Attempt to convert to Decimal instance.
        try:
            amount = decimal.Decimal(amount_str)
        except decimal.InvalidOperation:
            raise InvalidAmountError

        
        if any(
            math.isinf(amount), math.isnan(amount), # Raise exception if Decimal instance is infinite or not a number.
            amount <= 0,                    # Raise exception if Decimal instance is negative or zero.
            amount.as_tuple().exponent < -2 # Raise exception if Decimal instance has three or more decimal places.
            ):
            raise InvalidAmountError

        return amount

    # Method that returns True if the client confirms the transaction and False otherwise.
    def confirmTransaction(self, message: str) -> bool:
        # Prompt client to confirm the transaction.
        print(GUI_CONFIRM_TRANSACTION.format(message))
        confirm = queryMessage().upper()

        # Return True if the client confirms the transaction.
        return True if confirm == 'Y' else False

    # Method to print transaction history out to client.
    def showTransactionHistory(self):
        # Print header and column titles.
        print(GUI_TRANSACTION_HISTORY.format(self.first_name, self.last_name))
        print('DATE', ' '*11, 'TIME', ' '*7, 'TYPE', ' '*18, 'TRANSACTION AMOUNT (CAD)', ' '*3, 'CHEQUING BALANCE (CAD)', ' '*3, 'SAVINGS BALANCE (CAD)')

        # Loop through transaction history and print out each transaction in the specified format.
        for dt, *_, transaction_type, chequing_balance, savings_balance, amount_str in self.transaction_history:
            amount_str = amount_str.strip()
            date = datetime.strptime(dt.strip(), '%Y-%m-%d %H:%M:%S').strftime('%b %d, %Y')
            time = datetime.strptime(dt.strip(), '%Y-%m-%d %H:%M:%S').strftime('%H:%M:%S')
            amount = float(amount_str)
            print(
                f'{date:<16}',
                f'{time:<12}',
                f'{transaction_type:<32}',
                # Print negative transaction amounts in red and positive amounts in green.
                f'{amount:+15.2f}' if amount == 0 else (f'\033[91m{amount:+15.2f}\033[00m' if amount < 0 else f'\033[92m{amount:+15.2f}\033[00m'),
                f'{float(chequing_balance):26.2f}',
                f'{float(savings_balance):25.2f}')

# Main Program

# Get a client object and clear screen.
client = Client()
os.system('cls')

# Infinite loop for program cycle.
while True:
    transaction_type = None

    # Show the client menu.
    statusMessage(f'Logged in as {client.user_name}', Status.OK)
    hour = datetime.now().hour
    print(GUI_CLIENT_MENU.format(
        'morning' if hour < 12 else ('afternoon' if hour < 18 else 'evening'),
        client.first_name,
        client.chequing_balance,
        client.savings_balance))
    
    match queryMessage().upper():
        # Sign out.
        case '1':
            # Say goodbye to old client.
            os.system('cls')
            statusMessage(f'Logged out from {client.user_name}', Status.OK)

            # Get a new client.
            client = Client()
            os.system('cls')

        # Deposit.
        case '2':
            # Prompt client for amount to deposit.
            amount_str = queryMessage('Enter amount to deposit:')

            # Ensure the client entered a valid amount.
            try:
                amount = client.getValidAmount(amount_str)
            except InvalidAmountError:
                os.system('cls')
                statusMessage(f'Invalid amount: {amount_str}', Status.ERROR)
                continue

            # Prompt client for account to deposit the amount in.
            print(GUI_ACCOUNT_SELECTOR.format('deposit in'))
            account = queryMessage().upper()

            # Ensure the client selected a valid account.
            if account not in ('C', 'S'):
                os.system('cls')
                statusMessage('Invalid account.', Status.ERROR)
                continue

            # Confirm the transaction.
            if account == 'C' and client.confirmTransaction(f'Deposit {amount:.2f} CAD to chequing account'):
                # Add amount to chequing.
                client.chequing_balance += amount
                transaction_type = 'DEPOSIT_CHEQUING'
            if account == 'S' and client.confirmTransaction(f'Deposit {amount:.2f} CAD to savings account'):
                # Add amount to savings.
                client.savings_balance += amount
                transaction_type = 'DEPOSIT_SAVINGS'

        # Withdraw.
        case '3':
            # Prompt client for amount to withdraw.
            amount_str = queryMessage('Enter amount to withdraw:')

            # Ensure the client entered a valid amount.
            try:
                amount = client.getValidAmount(amount_str)
            except InvalidAmountError:
                os.system('cls')
                statusMessage(f'Invalid amount: {amount_str}', Status.ERROR)
                continue

            # Prompt client for account to withdraw the amount from.
            print(GUI_ACCOUNT_SELECTOR.format('withdraw from'))
            account = queryMessage().upper()

            # Ensure the client selected a valid account.
            if account not in ('C', 'S'):
                os.system('cls')
                statusMessage('Invalid account.', Status.ERROR)
                continue
                
            # Ensure the new balance is not negative.
            if account == 'C':
                # Ensure that new balance is not negative.
                if client.chequing_balance - amount < 0:
                    os.system('cls')
                    statusMessage('Insufficient funds in chequing account', Status.ERROR)
                    continue
                # Confirm the transaction.
                if client.confirmTransaction(f'Withdraw {amount:.2f} CAD from chequing account'):
                    # Subtract amount from chequing.
                    client.chequing_balance -= amount
                    transaction_type = 'WITHDRAW_CHEQUING'
            if account == 'S':
                # Ensure that new balance is not negative.
                if client.savings_balance - amount < 0:
                    os.system('cls')
                    statusMessage('Insufficient funds in savings account', Status.ERROR)
                    continue
                if client.confirmTransaction(f'Withdraw {amount:.2f} CAD from savings account'):
                    # Subtract amount from savings.
                    client.savings_balance -= amount
                    transaction_type = 'WITHDRAW_SAVINGS'

        # Transfer.
        case '4':
            # Prompt client for amount to transfer.
            amount_str = queryMessage('Enter amount to transfer:')

            # Ensure the client entered a valid amount.
            try:
                amount = client.getValidAmount(amount_str)
            except InvalidAmountError:
                os.system('cls')
                statusMessage(f'Invalid amount: {amount_str}', Status.ERROR)
                continue

            # Prompt client for account to transfer the amount to.
            print(GUI_ACCOUNT_SELECTOR.format('transfer to'))
            account = queryMessage().upper()

            # Ensure the client selected a valid account.
            if account not in ('C', 'S'):
                os.system('cls')
                statusMessage('Invalid account.', Status.ERROR)
                continue

            # Ensure the new balance is not negative and confirm the transaction.
            if account == 'C':
                # Ensure that new balance is not negative.
                if client.savings_balance - amount < 0:
                    os.system('cls')
                    statusMessage('Insufficient funds in savings account', Status.ERROR)
                    continue
                if client.confirmTransaction(f'Transfer {amount:.2f} CAD from savings to chequing account'):
                    # Add amount to chequing and subtract it from savings.
                    client.chequing_balance += amount
                    client.savings_balance  -= amount
                    transaction_type = 'TRANSFER_CHEQUING'
            if account == 'S':
                # Ensure that new balance is not negative.
                if client.chequing_balance - amount < 0:
                    os.system('cls')
                    statusMessage('Insufficient funds in chequing account', Status.ERROR)
                    continue
                if client.confirmTransaction(f'Transfer {amount:.2f} CAD from chequing to savings account'):
                    # Add amount to savings and subtract it from chequing.
                    client.savings_balance  += amount
                    client.chequing_balance -= amount
                    transaction_type = 'TRANSFER_SAVINGS'

        # Display transaction history.
        case '5':
            # Clear screen and show transaction history.
            os.system('cls')
            client.showTransactionHistory()

            # Wait for client to return to client menu.
            queryMessage('\nPress [Enter] to return to client menu:')
            os.system('cls')

        # Quit.
        case 'Q':
            # Clear screen, print goodbye message and exit program.
            os.system('cls')
            statusMessage('Thank you for choosing BoB.', Status.OK)
            sys.exit()

        # Invalid command.
        case  _ :
            # Clear screen and print error message.
            os.system('cls')
            statusMessage('Invalid command.', Status.ERROR)

    # If a transaction was made, write the transaction to the transactions file.
    if transaction_type is not None:
        # Get current date in form YYYY-MM-DD
        dt = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

        # Create transaction string and append to file.
        transaction = f'\n{dt}|{client.user_name}|{client.first_name}|{client.last_name}|{transaction_type}|{client.chequing_balance:.2f}|{client.savings_balance:.2f}|{amount:+.2f}'
        with open(TRANSACTIONS_FILE_NAME, 'a') as f:
            f.write(transaction)

        # Append transaction to transaction history variable.
        client.transaction_history.append(transaction.split('|'))

        # Confirm transaction to the client.
        match transaction_type:
            case 'DEPOSIT_CHEQUING' :statusMessage(f'Successfully deposited {amount:.2f} to chequing account.'               , Status.OK)
            case 'DEPOSIT_SAVINGS'  :statusMessage(f'Successfully deposited {amount:.2f} to savings account.'                , Status.OK)
            case 'WITHDRAW_CHEQUING':statusMessage(f'Successfully withdrawn {amount:.2f} from chequing account.'             , Status.OK)
            case 'WITHDRAW_SAVINGS' :statusMessage(f'Successfully withdrawn {amount:.2f} from savings account.'              , Status.OK)
            case 'TRANSFER_CHEQUING':statusMessage(f'Successfully transferred {amount:.2f} from savings to chequing account.', Status.OK)
            case 'TRANSFER_SAVINGS' :statusMessage(f'Successfully transferred {amount:.2f} from chequing to savings account.', Status.OK)
          
        # Wait for client to return to client menu.
        queryMessage('\nPress [Enter] to return to client menu:')
        os.system('cls')
