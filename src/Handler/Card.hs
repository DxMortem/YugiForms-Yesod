{-# LANGUAGE NoImplicitPrelude #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
module Handler.Card where

import Import
import Yesod.Form.Bootstrap3 (BootstrapFormLayout (..), renderBootstrap3)


--AForm
--data CardType = Monster | Magic | Trap

cardForm :: Maybe Card -> AForm Handler Card
cardForm card = Card
                <$> areq textField "Name" (cardName <$> card)
                <*> areq textField "Description" (cardDescription <$> card)
                <*> areq textField "Type" (cardType <$> card)--(selectField types) "Type" (cardType <$> card)
                --where
                  --types :: [(Text, CardType)]
                  --types = [("Monster", Monster), ("Magic", Magic), ("Trap", Trap)]

-- Create
getCardNewR :: Handler Html
getCardNewR = do
            (widget, encoding) <- generateFormPost $ renderBootstrap3 BootstrapBasicForm $ cardForm Nothing
            defaultLayout $ do
                let actionR = CardNewR
                $(widgetFile "CardCreate")

postCardNewR :: Handler Html
postCardNewR = do
                ((result,widget), encoding) <- runFormPost $ renderBootstrap3 BootstrapBasicForm $ cardForm  Nothing
                case result of
                     FormSuccess card -> do
                                 _ <- runDB $ insert card
                                 redirect CardListR
                     _ -> defaultLayout $ do
                        let actionR = CardNewR
                        $(widgetFile "CardCreate")
-- Listing
getCardListR :: Handler Html
getCardListR = do
            allcards <- runDB $ getAllCards
            defaultLayout $ do
                setTitle "Card List"
                let actionR = CardListR
                $(widgetFile "CardList")

getAllCards :: DB [Entity Card]
getAllCards = selectList [] [Asc CardType, Asc CardName]
