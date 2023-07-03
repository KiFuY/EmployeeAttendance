package com.fyp.attendance.WebSocket;

import com.fyp.attendance.Repository.ChatMessageRepository;
import com.fyp.attendance.Repository.UserRepository;
import com.fyp.attendance.entity.ChatMessage;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private final UserRepository userRepository;
    private final ChatMessageRepository chatMessageRepository;

    public WebSocketConfig(UserRepository userRepository, ChatMessageRepository chatMessageRepository) {
        this.userRepository = userRepository;
        this.chatMessageRepository = chatMessageRepository;
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(new SocketTextHandler(userRepository, chatMessageRepository), "/user");
    }

    public class SocketTextHandler extends TextWebSocketHandler {

        private final UserRepository userRepository;
        private final ChatMessageRepository chatMessageRepository;
        private List<WebSocketSession> sessions = new CopyOnWriteArrayList<>();

        public SocketTextHandler(UserRepository userRepository, ChatMessageRepository chatMessageRepository) {
            this.userRepository = userRepository;
            this.chatMessageRepository = chatMessageRepository;
        }

        @Override
        public void handleTextMessage(WebSocketSession session, TextMessage message) {
            // Parse the message from client
            String payload = message.getPayload();
            System.out.println("Received message: " + payload);

            String sender = payload.split(":")[0];
            String text = payload.split(":")[1];

            session.getAttributes().put("username", sender);

            System.out.println("Sender: " + sender);
            System.out.println("Text: " + text);

            // Save the message to the database
            ChatMessage chatMessage = new ChatMessage();
            chatMessage.setUsername_id(Integer.parseInt(sender)); // Convert the sender to username_id
            chatMessage.setMessage(text);
            chatMessageRepository.save(chatMessage);

            // Broadcast the message to other sessions
            for (WebSocketSession webSocketSession : sessions) {
                if (!webSocketSession.getId().equals(session.getId())) {
                    try {
                        webSocketSession.sendMessage(message);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
        }

        @Override
        public void afterConnectionEstablished(WebSocketSession session) {
            sessions.add(session);
        }

        @Override
        public void afterConnectionClosed(WebSocketSession session, CloseStatus status) {
            sessions.remove(session);
        }

        private String getUsernameFromSession(WebSocketSession session) {
            return (String) session.getAttributes().get("username");
        }
    }
}
