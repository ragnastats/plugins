#WORD
 
package RagnaStats;
 
# Perl includes
use strict;
use Data::Dumper;
use Time::HiRes;
use List::Util;
use Storable;
 
# Kore includes
use Settings;
use Plugins;
use Network;
use Globals;
 
 
Plugins::register("RagnaStats 2.0", "So many packets~", \&unload);
my $hooks = Plugins::addHooks(['mainLoop_post', \&loop],

								# Received packets
								####################
													
								# Server packets
								['packet/account_server_info', \&serverHandler],
								
								
								# Actor packets
								['packet/actor_exists', \&defaultHandler],
								['packet/actor_connected', \&defaultHandler],
								['packet/actor_moved', \&defaultHandler],
								['packet/actor_spawned', \&defaultHandler],
								#['packet/actor_died_or_disappeared', \&defaultHandler],
								['packet/actor_display', \&defaultHandler],
								#['packet/character_moves', \&defaultHandler],
								['packet/actor_action', \&defaultHandler],
								['packet/actor_info', \&defaultHandler],

								
								# Chat packets
								['packet/public_chat', \&defaultHandler],
								['packet/self_chat', \&defaultHandler],
								['packet/emoticon', \&defaultHandler],
								['packet/party_chat', \&defaultHandler],
								['packet/guild_chat', \&defaultHandler],
								['packet/local_broadcast', \&defaultHandler],
								

								# Chat room packets
								['packet/chat_created', \&defaultHandler],
								['packet/chat_info', \&defaultHandler],
								['packet/chat_removed', \&defaultHandler],
								['packet/chat_modified', \&defaultHandler],
								['packet/chat_request', \&defaultHandler],
								
								
								# Guild packets
								['packet/guild_allies_enemy_list', \&defaultHandler],
								['packet/guild_master_member', \&defaultHandler],
								['packet/guild_emblem', \&defaultHandler],
								['packet/guild_members_list', \&defaultHandler],
								['packet/guild_member_position_changed', \&defaultHandler],
								['packet/guild_leave', \&defaultHandler],
								['packet/guild_expulsion', \&defaultHandler],
								['packet/guild_broken', \&defaultHandler],
								['packet/guild_skills_list', \&defaultHandler],
								['packet/guild_expulsionlist', \&defaultHandler],
								['packet/guild_members_title_list', \&defaultHandler],
								['packet/guild_name', \&defaultHandler],
								['packet/guild_member_online_status', \&defaultHandler],
								['packet/guild_notice', \&defaultHandler],
								['packet/guild_position_changed', \&defaultHandler],
								['packet/guild_member_add', \&defaultHandler],
								['packet/guild_unally', \&defaultHandler],
								['packet/guild_alliance_added', \&defaultHandler],
								['packet/guild_emblem_update', \&defaultHandler],
								['packet/guild_info', \&defaultHandler],
								['packet/guild_member_map_change', \&defaultHandler],
								
								
								# Map packets
								['packet/map_loaded', \&defaultHandler],
								['packet/map_change', \&defaultHandler],
								['packet/map_changed', \&defaultHandler],
								['packet/map_property', \&defaultHandler],
								
								
								# Item packets
								['packet/item_exists', \&defaultHandler],
								['packet/item_appeared', \&defaultHandler],
								['packet/inventory_item_added', \&defaultHandler],
								['packet/item_disappeared', \&defaultHandler],
								['packet/use_item', \&defaultHandler],

								
								# Deal packets
								['packet/deal_request', \&defaultHandler],
								['packet/deal_begin', \&defaultHandler],
								['packet/deal_add_other', \&defaultHandler],
								['packet/deal_add_you', \&defaultHandler],
								['packet/deal_finalize', \&defaultHandler],
								['packet/deal_cancelled', \&defaultHandler],
								['packet/deal_complete', \&defaultHandler],
								
								
								# NPC packets
								['packet/npc_talk', \&defaultHandler],
								['packet/npc_talk_continue', \&defaultHandler],
								['packet/npc_talk_close', \&defaultHandler],
								['packet/npc_talk_responses', \&defaultHandler],
								['packet/npc_store_begin', \&defaultHandler],
								['packet/npc_store_info', \&defaultHandler],
								['packet/npc_sell_list', \&defaultHandler],
								['packet/npc_image', \&defaultHandler],
								['packet/npc_talk_number', \&defaultHandler],


								# Quest packets
								['packet/quest_all_list', \&defaultHandler],
								['packet/quest_all_mission', \&defaultHandler],
								['packet/quest_add', \&defaultHandler],
								['packet/quest_delete', \&defaultHandler],
								['packet/quest_update_mission_hunt', \&defaultHandler],
								['packet/quest_active', \&defaultHandler],
								
								
								# Rank packets
								['packet/top10_blacksmith_rank', \&defaultHandler],
								['packet/top10_alchemist_rank', \&defaultHandler],
								['packet/top10_taekwon_rank', \&defaultHandler],
								['packet/top10_pk_rank', \&defaultHandler],
								
								
								# Unhandled packets
								['packet/received_characters', \&defaultHandler],
								['packet/received_character_ID_and_Map', \&defaultHandler],
								['packet/stats_added', \&defaultHandler],
								['packet/stats_info', \&defaultHandler],
								['packet/storage_opened', \&defaultHandler],
								['packet/storage_item_added', \&defaultHandler],
								['packet/storage_item_removed', \&defaultHandler],
								['packet/mvp_item', \&defaultHandler],
								['packet/mvp_you', \&defaultHandler],
								['packet/mvp_other', \&defaultHandler],
								['packet/skills_list', \&defaultHandler],
								['packet/skill_use', \&defaultHandler],
								['packet/skill_use_location', \&defaultHandler],
								['packet/character_status', \&defaultHandler],
								['packet/skill_used_no_damage', \&defaultHandler],
								['packet/warp_portal_list', \&defaultHandler],
								['packet/area_spell', \&defaultHandler],
								['packet/cart_info', \&defaultHandler],
								['packet/cart_items_nonstackable', \&defaultHandler],
								['packet/cart_items_stackable', \&defaultHandler],
								['packet/vender_found', \&defaultHandler],
								['packet/vender_items_list', \&defaultHandler],
								['packet/shop_sold', \&defaultHandler],
								['packet/monster_ranged_attack', \&defaultHandler],
								['packet/skill_cast', \&defaultHandler],
								['packet/minimap_indicator', \&defaultHandler],
								['packet/item_skill', \&defaultHandler],
								['packet/manner_message', \&defaultHandler],
								['packet/GM_silence', \&defaultHandler],
								['packet/card_merge_list', \&defaultHandler],
								['packet/card_merge_status', \&defaultHandler],
								['packet/item_upgrade', \&defaultHandler],
								['packet/no_teleport', \&defaultHandler],
								['packet/sense_result', \&defaultHandler],
								['packet/map_change_cell', \&defaultHandler],
								['packet/character_name', \&defaultHandler],
								['packet/pet_info', \&defaultHandler],
								['packet/npc_talk_text', \&defaultHandler],
								['packet/player_equipment', \&defaultHandler],
								['packet/misc_effect', \&defaultHandler],
								['packet/friend_list', \&defaultHandler],
								['packet/friend_logon', \&defaultHandler],
								['packet/homunculus_property', \&defaultHandler],
								['packet/premium_rates_info', \&defaultHandler],
								['packet/GANSI_RANK', \&defaultHandler],
								['packet/message_string', \&defaultHandler],
								['packet/boss_map_info', \&defaultHandler],
								['packet/rental_time', \&defaultHandler],
								['packet/hotkeys', \&defaultHandler],
								['packet/show_eq', \&defaultHandler],
								['packet/skill_post_delay', \&defaultHandler],
								['packet/skill_post_delaylist', \&defaultHandler],
								['packet/open_buying_store', \&defaultHandler],
								['packet/open_buying_store_item_list', \&defaultHandler],
								['packet/buying_store_found', \&defaultHandler],
								['packet/buying_store_items_list', \&defaultHandler],
								['packet/buying_store_update', \&defaultHandler],
								['packet/buying_store_item_delete', \&defaultHandler],
								['packet/rates_info', \&defaultHandler],
								['packet/revolving_entity', \&defaultHandler],
								['packet/monster_hp_info', \&defaultHandler]
								
								# Sent packets
								# TODO: Add hooks in Network/Send/ServerType0.pm for sent packets, like NPC conversations?
								);
 
sub unload
{
	Plugins::delHooks($hooks);
}
 
sub loop
{

}

sub serverHandler
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");
	
	if($hook eq "packet/account_server_info")
	{
		my $server_info =
		{
			'accountID' => $args->{accountID},
			'accountSex' => $args->{accountSex},
			'servers' => $args->{servers}
		};
		
		$Data::Dumper::Indent = 0;       # Don't output whitespace	
		print(Dumper($server_info) . "\n");
	}
	else
	{
		print(Dumper($args));
	}
}

sub defaultHandler
{
	my($hook, $args) = @_;
	print("Hook: $hook \n");

    $Data::Dumper::Terse = 0;        # Output MORE!
    $Data::Dumper::Indent = 1;       # Output whitespace

#	print(Dumper(@_));
#	print("============\n");
}

1;