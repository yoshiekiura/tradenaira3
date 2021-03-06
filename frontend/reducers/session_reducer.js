import { RECEIVE_CURRENT_USER, RECEIVE_ERRORS, receiveCurrentUser, receiveErrors } from "../actions/session_actions";
import merge from 'lodash/merge';

const _nullUser = Object.freeze({
  currentUser: null
});

const sessionReducer = (state = _nullUser, action) => {
  Object.freeze(state);
  switch(action.type){
    case RECEIVE_CURRENT_USER:
      const currentUser = action.user;
      return merge({}, { currentUser })
    default:
      return state;
  }
}

export default sessionReducer;
