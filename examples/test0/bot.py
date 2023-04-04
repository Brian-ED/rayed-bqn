import discord
import random
intents = discord.Intents.default()

void = 0
mine = 10
currentvoid = 0

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')
    print(f'We have {void} void')
@client.event
async def on_message(message:discord.Message):    
    if message.content.startswith('!ping'):
        await message.channel.send('@Wafflepancakes')

        # void mining?

    if message.content.startswith('!mine'):
       await message.channel.send('You start mining and gain void!')
       global void
       void = void + random.randint(1, 20)

       #void spending

    if message.content.startswith('!weep'):
       await message.channel.send('You cry out some void.')

       void = 0 < void - random.randint(1, 20)


       #void checking

    if message.content.startswith('!void'):
         await message.channel.send(f'You have {void} void stored in your form.')

    if message.content.startswith('!lastchange'):
         await message.channel.send('changed weap to weep')


client.run('OTc1MTg4ODY1NDE1NTM2NjYx.Gy7CXB.vZw8pCa4Sm3yxzUoBoGZEY_14IvifcW3k99xBM')