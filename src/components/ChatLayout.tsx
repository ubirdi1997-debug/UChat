import React, { useState } from 'react';
import {
  Box,
  Drawer,
  List,
  ListItem,
  ListItemButton,
  ListItemText,
  ListItemIcon,
  AppBar,
  Toolbar,
  Typography,
  IconButton,
  Avatar,
  Menu,
  MenuItem,
  Divider,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material';
import MenuIcon from '@mui/icons-material/Menu';
import ChatIcon from '@mui/icons-material/Chat';
import AddIcon from '@mui/icons-material/Add';
import LogoutIcon from '@mui/icons-material/Logout';
import { useAuth } from '../contexts/AuthContext';
import { useChat } from '../contexts/ChatContext';
import ChatWindow from './ChatWindow';

const DRAWER_WIDTH = 280;

const ChatLayout: React.FC = () => {
  const { user, logout } = useAuth();
  const { currentRoom, joinRoom } = useChat();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const [newRoomDialogOpen, setNewRoomDialogOpen] = useState(false);
  const [newRoomName, setNewRoomName] = useState('');
  const [rooms] = useState([
    { id: 'general', name: 'General' },
    { id: 'random', name: 'Random' },
    { id: 'tech', name: 'Tech Talk' },
  ]);

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleMenuOpen = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleMenuClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    handleMenuClose();
    logout();
  };

  const handleRoomSelect = (roomId: string) => {
    joinRoom(roomId);
    setMobileOpen(false);
  };

  const handleNewRoomDialogOpen = () => {
    setNewRoomDialogOpen(true);
  };

  const handleNewRoomDialogClose = () => {
    setNewRoomDialogOpen(false);
    setNewRoomName('');
  };

  const handleCreateRoom = () => {
    if (newRoomName.trim()) {
      // In a real app, create room via API
      console.log('Creating room:', newRoomName);
      handleNewRoomDialogClose();
    }
  };

  const drawer = (
    <Box>
      <Toolbar>
        <ChatIcon sx={{ mr: 1 }} />
        <Typography variant="h6" noWrap>
          UChat
        </Typography>
      </Toolbar>
      <Divider />
      <List>
        <ListItem>
          <Button
            fullWidth
            variant="outlined"
            startIcon={<AddIcon />}
            onClick={handleNewRoomDialogOpen}
          >
            New Room
          </Button>
        </ListItem>
      </List>
      <Divider />
      <List>
        {rooms.map((room) => (
          <ListItem key={room.id} disablePadding>
            <ListItemButton
              selected={currentRoom === room.id}
              onClick={() => handleRoomSelect(room.id)}
            >
              <ListItemIcon>
                <ChatIcon />
              </ListItemIcon>
              <ListItemText primary={room.name} />
            </ListItemButton>
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <Box sx={{ display: 'flex', height: '100vh' }}>
      <AppBar
        position="fixed"
        sx={{
          width: { sm: `calc(100% - ${DRAWER_WIDTH}px)` },
          ml: { sm: `${DRAWER_WIDTH}px` },
        }}
      >
        <Toolbar>
          <IconButton
            color="inherit"
            edge="start"
            onClick={handleDrawerToggle}
            sx={{ mr: 2, display: { sm: 'none' } }}
          >
            <MenuIcon />
          </IconButton>
          <Typography variant="h6" noWrap component="div" sx={{ flexGrow: 1 }}>
            Encrypted Chat
          </Typography>
          <IconButton
            onClick={handleMenuOpen}
            size="small"
            sx={{ ml: 2 }}
          >
            <Avatar sx={{ width: 32, height: 32, bgcolor: 'secondary.main' }}>
              {user?.name?.charAt(0).toUpperCase() || 'U'}
            </Avatar>
          </IconButton>
          <Menu
            anchorEl={anchorEl}
            open={Boolean(anchorEl)}
            onClose={handleMenuClose}
          >
            <MenuItem disabled>
              <Typography variant="body2">{user?.email || 'Demo User'}</Typography>
            </MenuItem>
            <Divider />
            <MenuItem onClick={handleLogout}>
              <ListItemIcon>
                <LogoutIcon fontSize="small" />
              </ListItemIcon>
              <ListItemText>Logout</ListItemText>
            </MenuItem>
          </Menu>
        </Toolbar>
      </AppBar>
      <Box
        component="nav"
        sx={{ width: { sm: DRAWER_WIDTH }, flexShrink: { sm: 0 } }}
      >
        <Drawer
          variant="temporary"
          open={mobileOpen}
          onClose={handleDrawerToggle}
          ModalProps={{
            keepMounted: true,
          }}
          sx={{
            display: { xs: 'block', sm: 'none' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: DRAWER_WIDTH },
          }}
        >
          {drawer}
        </Drawer>
        <Drawer
          variant="permanent"
          sx={{
            display: { xs: 'none', sm: 'block' },
            '& .MuiDrawer-paper': { boxSizing: 'border-box', width: DRAWER_WIDTH },
          }}
          open
        >
          {drawer}
        </Drawer>
      </Box>
      <Box
        component="main"
        sx={{
          flexGrow: 1,
          width: { sm: `calc(100% - ${DRAWER_WIDTH}px)` },
          height: '100vh',
        }}
      >
        <Toolbar />
        <ChatWindow />
      </Box>

      <Dialog open={newRoomDialogOpen} onClose={handleNewRoomDialogClose}>
        <DialogTitle>Create New Room</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Room Name"
            fullWidth
            variant="outlined"
            value={newRoomName}
            onChange={(e) => setNewRoomName(e.target.value)}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={handleNewRoomDialogClose}>Cancel</Button>
          <Button onClick={handleCreateRoom} variant="contained">
            Create
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default ChatLayout;
